class CreateNodeInfo < ActiveRecord::Migration[6.1]
  def change
    create_table :nodes do |t|
      t.string :domain, null: false
      t.jsonb :info
      t.jsonb :info_override
      t.jsonb :nodeinfo
      t.jsonb :instance_data
      t.attachment :icon
      t.string :icon_remote_url
      t.attachment :thumbnail
      t.string :thumbnail_remote_url
      t.string :blurhash
      t.datetime :last_fetched_at
      t.integer :status, null: false, default: 0
      t.string :note, null: false, default: ''

      t.timestamps
    end

    add_index :nodes, :domain, unique: true
    add_index :nodes, :info, using: 'gin'
    add_index :nodes, :last_fetched_at
  end
end
