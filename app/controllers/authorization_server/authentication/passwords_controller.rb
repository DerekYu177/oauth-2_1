# frozen_string_literal: true

module AuthorizationServer
  module Authentication
    class PasswordsController < ApplicationController
      include CurrentOAuthState

      def new
      end

      def create
        authorization_params = params.permit(:username, :password).to_h
        
        method = AuthenticationMethods::Password.new(**authorization_params)

        if method.valid?
          # append to the AMR
        end
      end
    end
  end
end
