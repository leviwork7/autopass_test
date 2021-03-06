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
  has_many :order_promotions
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
    # 1. 刪除已不存在的促銷
    self.order_promotions.where.not(promotion: Promotion.ids).destroy_all

    # 2. 套用目前促銷
    Promotion.all.each do |promotion|
      unless promotion.implement!(self)
        self.order_promotions.where(promotion: self).destroy_all
      end
    end

    # 3. 總計價格調整金額
    total_adjustment = self.order_promotions.sum("adjustment_amount")

    self.total = item_total + total_adjustment
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
