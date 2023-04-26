# frozen_string_literal: true

module AuthorizationServer
  class Client
    # this is a class that stands in for a Client that has
    # already registered with the Authorization Server

    class << self
      def find(id)
        # replaces db lookup
        return unless id == new.client.id

        new
      end
    end

    delegate :id, to: :client

    def registered_redirect_uri?(uri)
      client.redirect_uris.include?(uri)
    end

    def callback_url(...)
      client.redirect_uri(...)
    end

    def client
      @client ||= ::Client::Authorization::RegistrationInfo.new
    end
  end
end
