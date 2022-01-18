class CreateOrderItems < ActiveRecord::Migration[6.1]
  def change
    create_table :order_items do |t|
      t.references :order, index: true
      t.references :product, index: true

      t.string :category
      t.integer :quantity
      t.integer :price

      t.timestamps
    end
  end
end
