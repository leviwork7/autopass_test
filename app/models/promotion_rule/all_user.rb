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
class PromotionRule::AllUser < PromotionRule
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # validations ...............................................................
  validates :maximum_quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :maximum_amount, numericality: { greater_than: 0 }, allow_nil: true
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  store :settings, coder: JSON, accessors: [
    :maximum_quantity,
    :maximum_amount,
    :period,
  ]

  store_enum period: ["weekly", "monthly"], allow_nil: true
  # class methods .............................................................
  # public instance methods ...................................................
  def pass_rule?(order)
    pass = true
    pass &= OrderPromotion.where(promotion: promotion).created_in(period_scope).count < maximum_quantity if maximum_quantity.present?
    pass &= OrderPromotion.where(promotion: promotion).created_in(period_scope).sum("adjustment_amount").abs < maximum_amount if maximum_amount.present?

    pass
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
  def period_scope
    case period
    when "weekly"
      Time.now.beginning_of_week..Time.now.end_of_week
    when "monthly"
      Time.now.beginning_of_month..Time.now.end_of_month
    else
      []
    end
  end
end
