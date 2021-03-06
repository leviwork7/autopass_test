# frozen_string_literal: true

# == Schema Information
#
# Table name: order_items
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  product_id :integer
#  category   :string
#  quantity   :integer
#  price      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_order_items_on_order_id    (order_id)
#  index_order_items_on_product_id  (product_id)
#
class OrderItem < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :order
  belongs_to :product
  # validations ...............................................................
  validates :quantity, numericality: { greater_than: 0 }, presence: :true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, presence: :true
  # callbacks .................................................................
  after_initialize :initialize_by_category, if: :new_record?
  # scopes ....................................................................
  # additional config .........................................................
  enum category: {
    normal: "normal",
    free: "free",
  }
  attribute :category, :string, default: "normal"
  attribute :quantity, :integer, default: 1
  # class methods .............................................................
  # public instance methods ...................................................
  def subtotal
    quantity * price
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
  def initialize_by_category
    case category
    when "normal"
      self.price = product.price
    when "free"
      self.price = 0
      self.quantity = 1
    end
  end
end
