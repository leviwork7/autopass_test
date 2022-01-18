module StoreEnhanceableConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def store_enum(allow_nil: false, **args)
      args.each do |key, values|
        raise ArgumentError.new("value must be array!") unless values.is_a?(Array)

        define_method "#{key}_valid?" do
          instance_value = self.send(key)

          return true if instance_value.nil? && allow_nil
          if values.map(&:to_s).include? instance_value.to_s
            true
          else
            errors.add(key, "value is not valid!")
            false
          end
        end
        self.send("before_validation", "#{key}_valid?".to_sym)
      end
    end
  end
end
