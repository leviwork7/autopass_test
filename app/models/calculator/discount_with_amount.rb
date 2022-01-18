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
class Calculator::DiscountWithAmount < Calculator
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
  ]
  store_enum calc_type: ["fixed", "percentage"]
  # class methods .............................................................
  def compute(amount)
    case calc_type
    when "percentage"
      (amount * calc_value).floor
    when "fixed"
      [amount, calc_value].min
    else
      0
    end
  end
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end
