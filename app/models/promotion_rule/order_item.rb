# == Schema Information
#
# Table name: promotion_rules
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
#  index_promotion_rules_on_product_id    (product_id)
#  index_promotion_rules_on_promotion_id  (promotion_id)
#
class PromotionRule::OrderItem < PromotionRule
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :product
  # validations ...............................................................
  validates :minimum_quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :minimum_amount, numericality: { greater_than: 0 }, allow_nil: true
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  store :settings, coder: JSON, accessors: [
    :minimum_quantity,
    :minimum_amount,
  ]
  # class methods .............................................................
  # public instance methods ...................................................
  def pass_rule?(order)
    order_item = order.order_items.find_by_product_id(self.product_id)

    return false if order_item.nil?
    return false unless order_item.quantity >= minimum_quantity if minimum_quantity.present?
    return false unless order_item.subtotal >= minimum_amount if minimum_amount.present?

    true
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
