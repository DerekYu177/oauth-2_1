class CreateAsOAuthState < ActiveRecord::Migration[7.0]
  def change
    create_table :as_oauth_states, id: false do |t|
      t.string :id, primary_key: true
      t.text :state

      t.timestamps
    end
  end
end
