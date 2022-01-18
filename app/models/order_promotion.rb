# frozen_string_literal: true

# == Schema Information
#
# Table name: order_promotions
#
#  id                  :integer          not null, primary key
#  promotion_id        :integer
#  promotion_action_id :integer
#  order_id            :integer
#  order_item_id       :integer
#  free_order_item_id  :integer
#  adjustment_amount   :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_order_promotions_on_free_order_item_id   (free_order_item_id)
#  index_order_promotions_on_order_id             (order_id)
#  index_order_promotions_on_order_item_id        (order_item_id)
#  index_order_promotions_on_promotion_action_id  (promotion_action_id)
#  index_order_promotions_on_promotion_id         (promotion_id)
#
class OrderPromotion < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :promotion
  belongs_to :promotion_action

  belongs_to :order
  belongs_to :order_item, optional: true
  belongs_to :free_order_item, optional: true, dependent: :destroy, class_name: "OrderItem"
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  scope :created_in, -> (scope = nil) { scope.present? ? self.where(created_at: scope) : self }
  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end
