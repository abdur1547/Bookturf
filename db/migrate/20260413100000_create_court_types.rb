class CreateCourtTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :court_types do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon

      t.timestamps
    end

    # Indexes
    add_index :court_types, :name, unique: true
    add_index :court_types, :slug, unique: true
  end
end
