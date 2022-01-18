# == Schema Information
#
# Table name: promotion_actions
#
#  id           :integer          not null, primary key
#  type         :string
#  promotion_id :integer
#  product_id   :integer
#  settings     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_promotion_actions_on_product_id    (product_id)
#  index_promotion_actions_on_promotion_id  (promotion_id)
#
class PromotionAction::OrderDiscount < PromotionAction
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # validations ...............................................................
  validates_presence_of :calc_type, :calc_value
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  store :settings, coder: JSON, accessors: [
    :calc_type,
    :calc_value,
    :maximum_amount,
    :quota_amount,
  ]

  store_enum calc_type: ["fixed", "percentage"]
  # class methods .............................................................
  # public instance methods ...................................................
  def perform!(order)
    order_promotion = order.order_promotions.find_or_create_by(
      promotion: promotion,
      promotion_action_id: self.id,
    )
    order_promotion.adjustment_amount = [
      calc_adjustment(order.item_total),  # 原始金額
      rest_quota_amount(order),           # 剩餘額度
      maximum_amount,                     # 上限金額
    ].compact.min * -1

    order_promotion.save!
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
  def rest_quota_amount(order)
    return nil if quota_amount.blank?

    used_quota = OrderPromotion.joins(:order)
                               .where(promotion: promotion)
                               .where.not(order: order)
                               .where("orders.user_id = ?", order.user_id)
                               .sum("adjustment_amount").to_i

    quota_amount - (used_quota * -1)
  end
end
