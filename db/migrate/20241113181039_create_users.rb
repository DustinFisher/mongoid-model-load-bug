class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.timestamps

      t.string :username, null: false

      t.index :username, unique: true
    end
  end
end
