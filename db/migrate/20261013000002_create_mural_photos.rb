class CreateMuralPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :mural_photos do |t|
      t.references :mural, null: false, foreign_key: true
      t.string :alt_text
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_check_constraint :mural_photos, "position >= 0", name: "mural_photos_position_nonnegative"
  end
end
