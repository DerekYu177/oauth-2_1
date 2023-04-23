# frozen_string_literal: true

module AuthorizationServer
  module AuthenticationMethods
    class Password
      attr_reader :username, :password

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
