class CreateUser < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :uuid

      t.timestamps
    end
  end
end
