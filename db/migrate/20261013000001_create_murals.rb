class CreateMurals < ActiveRecord::Migration[8.1]
  def change
    create_table :murals do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :location
      t.integer :year
      t.string :client
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: false
      t.timestamps
    end

    add_index :murals, :slug, unique: true
    add_check_constraint :murals, "position >= 0", name: "murals_position_nonnegative"
  end
end
