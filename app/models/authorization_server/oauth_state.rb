# frozen_string_literal: true

module AuthorizationServer
  # maintains the state if the user needs to be authenticated
  class OAuthState < ApplicationRecord
    self.table_name = 'as_oauth_states'

    include ULIDable

    typed_store :state do |s|
      s.string :redirect_uri
      s.string :code_challenge
      s.integer :client_id
      s.string :user_uuid
    end

    def to_param
      { osid: id } 
    end
  end
end
