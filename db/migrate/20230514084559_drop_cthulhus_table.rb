class DropCthulhusTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :cthulhus do |t|
      t.text :story
      t.timestamps
    end
  end
end
