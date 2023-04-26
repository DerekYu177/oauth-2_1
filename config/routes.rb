Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :authorization_server, path: :as do
    # https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-08#name-protocol-endpoints

    # used by the client to obtain authorization from the resource owner
    # via user agent redirection.
    resource :authorization, only: %i(), path: 'authorize' do
      get '/', action: :new
      post '/', action: :create
    end

    # used by the client to exchange an authorization grant
    # for an access token, typically with client authentication.
    resource :token, only: %i() do
      get '/', action: :new
      post '/', action: :create
    end

    # the authorization controller only acts as a generic interface for a specific
    # authorization method, which upon completion can redirect back to the
    # namespace :authorization_methods, path: :method do
    #   resource :password, only: %i() do
    #     get '/', action: :new
    #     post '/', action: :create
    #   end
    # end
  end

  resource :client, only: %i() do
    get '/without', action: :without_authorization, as: :without_authorization
    get '/callback', action: :with_authorization_code_callback, as: :callback
  end

  resource :resource do
  end
end
