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

    def new
      validate_client_id!
      validate_redirect_uri!
      
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
      
      @client = AuthorizationServer::Client.find(client_id)
      oauth_error!(:unauthorized_client) unless @client
    end

    def validate_redirect_uri!
      redirect_uri = authorization_request_params[:redirect_uri]
      
      oauth_error!(:invalid_request) unless @client.registered_redirect_uri?(redirect_uri)
    end

    def oauth_error!(error)
      # TODO
    end

    def authorization_request_params
      params.permit(*AUTHORIZATION_REQUEST_PARAMS)
    end
  end
end
