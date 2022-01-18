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
class PromotionAction::OrderItemDiscount < PromotionAction
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :product
  # validations ...............................................................
  validates_presence_of :calc_type, :calc_value
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  store :settings, coder: JSON, accessors: [
    :calc_type,
    :calc_value,
  ]
  store_enum calc_type: ["fixed", "percentage"]
  # class methods .............................................................
  # public instance methods ...................................................
  def perform!(order)
    order_item = order.order_items.find_by_product_id(self.product_id)
    return false if order_item.nil?

    order_promotion = order.order_promotions.find_or_create_by(
      promotion: promotion,
      promotion_action_id: self.id,
      order_item: order_item
    )
    order_promotion.adjustment_amount = calc_adjustment(order_item.subtotal) * -1
    order_promotion.save!
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
