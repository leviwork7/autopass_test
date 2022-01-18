# frozen_string_literal: true

class CreatePromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :promotions do |t|
      t.string :type
      t.string :title

      t.timestamps
    end

    create_table :promotion_rules do |t|
      t.string :type
      t.references :promotion
      t.references :product

      t.text :settings

      t.timestamps
    end

    create_table :promotion_actions do |t|
      t.string :type
      t.references :promotion
      t.references :product

      t.text :settings

      t.timestamps
    end
  end
end
