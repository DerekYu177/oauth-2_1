# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(AuthorizationServer::AuthorizationsController, type: :request) do
  describe '#new' do
    let(:response_type) { 'code' }
    let(:client_id) { AuthorizationServer::Client.new.id }
    let(:code_challenge) { Base64.encode64(Digest::SHA2.new(256).hexdigest('123')) }
    let(:code_challenge_method) { 's256' }
    let(:redirect_uri) { AuthorizationServer::Client.new.callback_url }
    let(:scope) { 'email' }
    let(:state) { SecureRandom.uuid }

    let(:authorization_params) do
      {
        response_type: response_type,
        client_id: client_id,
        code_challenge: code_challenge,
        code_challenge_method: code_challenge_method,
        redirect_uri: redirect_uri,
        scope: scope,
        state: state,
      }
    end

    subject do
      get(authorization_server_authorization_path(authorization_params))
      response
    end

    context 'succeeds' do
      it { is_expected.to(have_http_status(:ok)) }
    end

    shared_examples 'fails' do |error, message, renders:|
      if renders == :error
        it 'with error page' do
          is_expected.to(render_template('authorization_server/authorizations/error'))

          node = Capybara::Node::Simple.new(response.body)
          expect(node.find('span[error-type="name"]').text).to(eq(error.to_s))
          expect(node.find('span[error-type="message"]').text).to(eq(message))
        end
      elsif renders == nil
        it 'with redirect_uri' do
          subject

          uri = Addressable::URI.parse(response.location)
          expect(uri.query_values.symbolize_keys).to(include(
            error: error.to_s,
            error_description: message,
            state: state,
            iss: 'authorization.example.dev'
          ))
        end
      end
    end

    context 'when missing required parameter' do
      let(:client_id) { nil }
      it_behaves_like 'fails', :invalid_request, 'missing required parameter', renders: :error
    end

    context 'when missing required redirect_uri parameter' do
      let(:redirect_uri) { nil }
      it_behaves_like 'fails', :missing_redirect_uri, 'redirect_uri is missing', renders: :error
    end

    context 'when mismatch redirect_uri parameter' do
      let(:redirect_uri) { 'https://hacker.io/callback' }
      it_behaves_like 'fails', :mismatching_redirect_uri, 'redirect_uri does not match list of authorized [redirect_uri]', renders: :error
    end

    context 'when client cannot request an authorization code using this method' do
      let(:client_id) { 'clearly-incorrect-client-uuid' }
      it_behaves_like 'fails', :unauthorized_client, 'this client is not authorized to request an authorization code using this method', renders: nil
    end

    context 'returns access_denied' do
      context 'when resource owner declines the request' do
      end

      context 'when authorization server declines the request' do
      end
    end

    context 'when the response_type is not authorization_code' do
      let(:response_type) { 'implicit' }
      it_behaves_like 'fails', :unsupported_response_type, 'the authentication service does not support this response type', renders: nil
    end

    context 'returns invalid_scope' do
      context 'when requested scope is invalid' do
      end
    end

    context 'returns server_error' do
      context 'when internal error occurs' do
      end
    end

    context 'returns temporarily_unavailable' do
      context 'when server overwhelmed' do
      end
    end
  end
end
