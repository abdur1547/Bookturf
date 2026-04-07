class CreateUserRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.references :assigned_by, foreign_key: { to_table: :users }
      t.datetime :assigned_at, null: false

      t.timestamps
    end

    # Unique constraint: a user can have a role only once
    add_index :user_roles, [ :user_id, :role_id ], unique: true
  end
end
