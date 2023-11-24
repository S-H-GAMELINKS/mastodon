require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddSettingsToAccounts < ActiveRecord::Migration[6.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured { add_column_with_default :accounts, :settings, :jsonb, default: "{}", allow_null: false }
    safety_assured { add_index :accounts, :settings, using: 'gin', algorithm: :concurrently, name: :index_accounts_on_settings }
  end

  def down
    remove_index :accounts, name: :index_accounts_on_settings
    remove_column :accounts, :settings
  end
end
