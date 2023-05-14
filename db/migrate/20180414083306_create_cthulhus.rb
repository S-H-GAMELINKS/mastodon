# frozen_string_literal: true

class CreateCthulhus < ActiveRecord::Migration[5.2]
  def change
    create_table :cthulhus, &:timestamps
  end
end
