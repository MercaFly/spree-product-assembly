module Spree
  module Stock
    class Quantifier
      attr_reader :stock_items, :variant, :recursion
  
      def initialize(variant, recursion=true)
        @variant = variant
        @stock_items = @variant.stock_items.with_active_stock_location
        @recursion = recursion
      end
  
      def total_on_hand
        if variant.parts.exists? && recursion
          variant.parts_variants.map do |part|
            ## only calculate 1 depth parts, set recursion false
            t = Quantifier.new(part.part, false).total_on_hand
            d = part.count
            t/d
          end.min
        else
          if variant.should_track_inventory?
            stock_items.sum(:count_on_hand)
          else
            Float::INFINITY
          end
        end
      end

      def backorderable?
        if variant.parts.exists?
          false
        else
          stock_items.any?(&:backorderable)
        end
      end
  
      def can_supply?(required = 1)
        variant.available? && (total_on_hand >= required || backorderable?)
      end
    end
  end
end
  