# frozen_string_literal: true

# == Schema Information
#
# Table name: calculators
#
#  id              :integer          not null, primary key
#  type            :string
#  calculable_type :string
#  calculable_id   :bigint
#  settings        :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_calculators_on_calculable_type_and_calculable_id  (calculable_type,calculable_id)
#  index_calculators_on_id_and_type                        (id,type)
#
class Calculator::DiscountOnOrder < Calculator
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
  def compute(order, promotion)
    [
      discount_amount(order.item_total),   # 原始金額
      rest_quota_amount(order, promotion), # 剩餘額度
      maximum_amount,                      # 上限金額
    ].compact.min
  end
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
  def discount_amount(amount)
    case calc_type
    when "percentage"
      (amount * calc_value).floor
    when "fixed"
      [amount, calc_value].min
    else
      0
    end
  end

  def rest_quota_amount(order, promotion)
    return nil if quota_amount.blank?

    used_quota = OrderPromotion.joins(:order)
                               .where(promotion: promotion)
                               .where.not(order: order)
                               .where("orders.user_id = ?", order.user_id)
                               .sum("adjustment_amount").to_i

    quota_amount - (used_quota * -1)
  end
end
