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
class PromotionAction < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  include StoreEnhanceableConcern
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :promotion
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  def perform!(order)
    raise "Not Implement Error!"
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
  def calc_adjustment(amount)
    case calc_type
    when "percentage"
      (amount * calc_value).floor
    when "fixed"
      [amount, calc_value].min
    else
      0
    end
  end
end
