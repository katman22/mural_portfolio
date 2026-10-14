class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :users, :username, unique: true
    add_check_constraint :users, "username = lower(btrim(username)) AND length(username) > 0", name: "users_username_normalized"
    add_check_constraint :users, "length(password_digest) > 0", name: "users_password_digest_present"
  end
end
