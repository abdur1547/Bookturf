class CreateCourts < ActiveRecord::Migration[7.1]
  def change
    create_table :courts do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :court_type, null: false, foreign_key: true

      t.string :name, null: false
      t.text :description
      t.boolean :is_active, default: true, null: false
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end

    # Indexes
    add_index :courts, [ :venue_id, :name ], unique: true
    add_index :courts, :is_active
  end
end
