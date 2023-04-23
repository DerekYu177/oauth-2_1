# frozen_string_literal: true

module AuthorizationServer
  class Client
    # this is a class that stands in for a Client that has
    # already registered with the Authorization Server

    def callback_url(...)
      Client::Authorization::RegistrationInfo.new.redirect_uri(...)
    end
  end
end
