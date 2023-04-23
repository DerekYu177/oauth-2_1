# frozen_string_literal: true

require 'digest/sha2'
require 'base64'

class ClientController < ApplicationController
  def without_authorization
    # begins the authorization to access a protected resource
    # for https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-08#name-protocol-flow
    # 
    # We will assume that this flow begins without authorization, so we need to request authentication
    # from the authorization server

    # for more details: https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-08#name-authorization-request

    client = Client::Authorization::RegistrationInfo.new

    # in any request, we store the code_verifier (required) and the state (optional)
    # temporarily as a way of verifying each authorization request/response pair
    # and to maintain state between the request and the callback.
    # in our scenario, we use the state to fetch the code verifier (implementation detail)

    code_verifier = SecureRandom.uuid # 43 <= |code_verifier| <= 128
    state = SecureRandom.uuid
    session[state] = { code_verifier: code_verifier }
    
    # we will use following S256 code_verifier transformation
    # code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
    code_challenge = Base64.encode64(Digest::SHA2.new(256).hexdigest(code_verifier))

    authorization_request_params = {}
    authorization_request_params[:response_type]          = 'code'                # MUST
    authorization_request_params[:client_id]              = client.id             # MUST
    authorization_request_params[:code_challenge]         = code_challenge        # MUST
    authorization_request_params[:code_challenge_method]  = 's256'                # MUST
    authorization_request_params[:redirect_uri]           = client.redirect_uri   # Optional
    authorization_request_params[:scope]                  = 'email'               # Optional
    authorization_request_params[:state]                  = state                 # Optional
    
    @redirect_url = authorization_server_authorization_path(**authorization_request_params)
  end

  def with_authorization_code_callback
    # ext: https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-08#section-1.3.1 
    # A temporary credential used to obtain an access token.
    # Instead of the client requesting authorization directly from the resource owner,
    # the client directs the resource owner to an authorization server (via its user agent,
    # which in turn directs the resource owner back to the client with the authorization code).
    # The client can then exchange the authorization code for an access token.
    #
    # Notes:
    # This is the callback endpoint on the client.
    # We now need to exchange the authorization code for an access token.
    # 
    # This is also known as the Client Redirection Endpoint, and is where the authorization server
    # redirects the user agent back to after completing its interaction with the resource owner.
    # This endpoint must be established with the authorization server during the client registration process
    @redirect_url = nil
  end
end
