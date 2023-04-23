# frozen_string_literal: true

module Client
  module Authorization
    class RegistrationInfo
      # models the information that would have been registered
      # with the authorization server (AuthorizationServer::Client)

      def id
        '13760de5-b6dd-4a74-995f-eb856aa59c12'
      end

      def redirect_uri(...)
        url_helpers.callback_client_url(...)
      end

      private

      def url_helpers
        url_helpers ||= Rails.application.routes.url_helpers
      end
    end
  end
end
