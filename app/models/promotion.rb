# == Schema Information
#
# Table name: promotions
#
#  id         :integer          not null, primary key
#  type       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Promotion < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  has_many :rules, class_name: "PromotionRule", dependent: :destroy
  has_many :actions, class_name: "PromotionAction", dependent: :destroy

  has_many :order_promotions, dependent: :destroy
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  def eligible?(order)
    rules.inject(true) do |result, rule|
      result &= rule.pass_rule?(order)
      result
    end
  end

  def implement!(order)
    return false unless eligible?(order)

    actions.each do |action|
      action.perform!(order)
    end

    true
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
end
