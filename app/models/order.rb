# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  total      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_orders_on_user_id  (user_id)
#
class Order < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :user
  has_many :order_items
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  attribute :total, :integer, default: 0
  # class methods .............................................................
  # public instance methods ...................................................
  def item_total
    self.order_items.sum("order_items.price * order_items.quantity")
  end

  def calc_total
    self.total = item_total
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
