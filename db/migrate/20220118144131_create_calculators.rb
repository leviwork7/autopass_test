# frozen_string_literal: true

class CreateCalculators < ActiveRecord::Migration[6.1]
  def change
    create_table :calculators do |t|
      t.string "type"
      t.string "calculable_type"
      t.bigint "calculable_id"

      t.text :settings

      t.timestamps
    end

    add_index(:calculators, [:id, :type])
    add_index(:calculators, [:calculable_type, :calculable_id])
  end
end
