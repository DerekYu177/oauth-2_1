# frozen_string_literal: true

module AuthorizationServer
  module AuthorizationGrants
    class AuthorizationCode < ApplicationRecord
      self.table_name = 'as_authorization_code_grants'

      include ULIDable

      after_initialize :set_expires_at

      validates :redirect_uri, :code_challenge, :client_id, presence: true

      private

      def set_expires_at
        self.expires_at = 10.minutes.from_now
      end
    end
  end
end
