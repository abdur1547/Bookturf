class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :is_custom, default: false, null: false

      t.timestamps
    end

    # Indexes
    add_index :roles, :name, unique: true
    add_index :roles, :slug, unique: true
    add_index :roles, :is_custom
  end
end
