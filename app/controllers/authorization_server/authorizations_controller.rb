# frozen_string_literal: true

module AuthorizationServer
  class AuthorizationsController < ApplicationController
    AUTHORIZATION_REQUEST_PARAMS = %i(
      response_type 
      client_id 
      code_challenge 
      code_challenge_method 
      redirect_uri 
      scope 
      state
    )
    
    # https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-08#section-4.1.1
    before_action(
      :validate_client_id!,
      :validate_redirect_uri!,
      :validate_response_type!,
      only: :new,
    )

    def new
      render(AuthenticationMethods::Password.uri)
      # authenticates the client 
      # currently, we should only ask for a user name and password
    end

    def create
      authorization_params = params.permit(:username, :password).to_h
      
      method = AuthenticationMethods::Password.new(**authorization_params)

      if method.valid?
        AuthorizationGrants::AuthorizationCode.new
      end
      # client submits authentication
      # if successful
      #   AccessToken
      # else
      #   Error 
      # end

      # the resource owner provides an authorization grant
      # that has 3 different grant types:
      # AuthorizationCode
      # RefreshToken
      # ClientCredentials
      #
      # AuthorizationCode
      # https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-08#section-1.3.1 
      # Used to obtain an access token

      # redirects back to the original caller
      # In this case, to the Client#with_authentication
      # let's assume that the Client has Registered with the Authorization server
      client = AuthorizationServer::Client.new

      authorization_response_params = {}
      authorization_response_params[:code] = nil
      authorization_response_params[:state] = nil
      authorization_response_params[:iss] = nil

      @redirect_url = client.callback_url(**authorization_response_params)
    end

    private

    def validate_client_id!
      client_id = authorization_request_params[:client_id]
      return oauth_error!(:invalid_request) unless client_id
      
      @client = AuthorizationServer::Client.find(client_id)
      return oauth_error!(:unauthorized_client) unless @client
    end

    def validate_redirect_uri!
      redirect_uri = authorization_request_params[:redirect_uri]
      
      return oauth_error!(:missing_redirect_uri) unless redirect_uri
      # oauth_error!(:invalid_redirect_uri) unless URI.new(redirect_uri).valid?
      return oauth_error!(:mismatching_redirect_uri) unless @client.registered_redirect_uri?(redirect_uri)
    end

    def validate_response_type!
      response_type = authorization_request_params[:response_type]
      return oauth_error!(:unsupported_response_type) unless response_type == 'code'
    end

    def oauth_error!(error)
      case error
      when :invalid_request
        inform_resource_owner!(error, 'missing required parameter')
      when :missing_redirect_uri
        inform_resource_owner!(error, 'redirect_uri is missing')
      when :invalid_redirect_uri
        inform_resource_owner!(error, 'redirect_uri is malformed')
      when :mismatching_redirect_uri
        inform_resource_owner!(error, 'redirect_uri does not match list of authorized [redirect_uri]')
      # assume that redirect_uri is valid from here on out
      when :unauthorized_client
        inform_client!(error, 'this client is not authorized to request an authorization code using this method')
      when :unsupported_response_type
        inform_client!(error, 'the authentication service does not support this response type')
      else
      end
    end

    def inform_resource_owner!(error, message)
      @error = error
      @message = message
      render(:error)
    end

    def inform_client!(error, message)
      redirect_uri = authorization_request_params[:redirect_uri]
      uri = Addressable::URI.parse(redirect_uri)
      uri.query_values = {
        error: error,
        error_description: message,
        state: authorization_request_params[:state],
        iss: 'authorization.example.dev',
      }

      redirect_to(uri.to_s, allow_other_host: true)
    end

    def authorization_request_params
      params.permit(*AUTHORIZATION_REQUEST_PARAMS)
    end
  end
end
