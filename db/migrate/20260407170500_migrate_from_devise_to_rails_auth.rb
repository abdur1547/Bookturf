class MigrateFromDeviseToRailsAuth < ActiveRecord::Migration[8.1]
  def change
    # Rename encrypted_password to password_digest for has_secure_password
    rename_column :users, :encrypted_password, :password_digest

    # Remove Devise-specific columns that are no longer needed
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime

    # Remove Devise tracking columns (optional - remove if you don't need tracking)
    # Comment these out if you want to keep tracking
    remove_column :users, :sign_in_count, :integer if column_exists?(:users, :sign_in_count)
    remove_column :users, :current_sign_in_at, :datetime if column_exists?(:users, :current_sign_in_at)
    remove_column :users, :last_sign_in_at, :datetime if column_exists?(:users, :last_sign_in_at)
    remove_column :users, :current_sign_in_ip, :string if column_exists?(:users, :current_sign_in_ip)
    remove_column :users, :last_sign_in_ip, :string if column_exists?(:users, :last_sign_in_ip)
  end
end
