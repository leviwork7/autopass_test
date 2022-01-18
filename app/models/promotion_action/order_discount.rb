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
  use_calculator("Calculator::DiscountOnOrder")
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  def perform!(order)
    order_promotion = order.order_promotions.find_or_create_by(
      promotion: promotion,
      promotion_action_id: self.id,
    )
    order_promotion.adjustment_amount = compute(order, promotion) * -1

    order_promotion.save!
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
