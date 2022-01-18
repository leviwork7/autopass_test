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
class PromotionRule::Order < PromotionRule
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
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
    pass = true
    pass &= order.item_total >= minimum_amount if minimum_amount.present?
    pass &= order.order_items.count >= minimum_quantity if minimum_quantity.present?
    pass
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
