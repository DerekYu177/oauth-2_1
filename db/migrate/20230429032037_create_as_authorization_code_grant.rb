class CreateAsAuthorizationCodeGrant < ActiveRecord::Migration[7.0]
  def change
    create_table :as_authorization_code_grants, id: false do |t|
      t.string :id, primary_key: true

      t.string :redirect_uri, required: true
      t.string :code_challenge, required: true
      t.integer :client_id, required: true
      t.datetime :expires_at, required: true
      t.timestamps
    end
  end
end
