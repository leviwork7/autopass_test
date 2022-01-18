module CalculatableConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def use_calculator(calculator_class_name)
      self.send(:has_one, :calculator,
        as: :calculable,
        class_name: calculator_class_name,
        inverse_of: :calculable,
        dependent: :destroy
      )

      self.send(:accepts_nested_attributes_for, :calculator)
      self.send(:delegate, :compute, to: :calculator)
    end
  end
end
