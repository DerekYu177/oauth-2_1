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

    shared_examples 'fails' do |with:, message:|
      # TODO
    end

    context 'returns invalid_request' do
      context 'when missing required parameter' do
      end

      context 'when includes a parameter more than once' do
      end

      context 'when parameter is malformed' do
      end
    end

    context 'returns unauthorized_client' do
      context 'when client cannot request an authorization code using this method' do
      end
    end

    context 'returns access_denied' do
      context 'when resource owner declines the request' do
      end

      context 'when authorization server declines the request' do
      end
    end

    context 'returns unsupported_response_type' do
      context 'when AS does not support obtaining an authorization code using this method' do
      end
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
