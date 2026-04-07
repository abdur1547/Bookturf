class CreatePermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :permissions do |t|
      t.string :resource, null: false
      t.string :action, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    # Indexes
    add_index :permissions, :name, unique: true
    add_index :permissions, [ :resource, :action ], unique: true
    add_index :permissions, :resource
  end
end
