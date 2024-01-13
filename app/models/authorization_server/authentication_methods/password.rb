# frozen_string_literal: true

module AuthorizationServer
  module AuthenticationMethods
    class Password
      attr_reader :username, :password

      class << self
        def uri(...)
          url_helper.new_authorization_server_authorization_authentication_password_path(...)
        end

        private

        def url_helper
          @url_helper ||= Rails.application.routes.url_helpers
        end
      end

      def initialize(username:, password:)
        @username = username
        @password = password
      end

      def valid?
        # don't do this.
        # use proper authentication techniques to validate the password is correct.
        # Rails can help you.
        username == 'admin' && password == 'password'
      end
    end
  end
end
