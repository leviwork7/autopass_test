# frozen_string_literal: true

class CreateOrderPromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :order_promotions do |t|
      t.references :promotion
      t.references :promotion_action

      t.references :order
      t.references :order_item
      t.references :free_order_item

      t.integer :adjustment_amount

      t.timestamps
    end
  end
end
