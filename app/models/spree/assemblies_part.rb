module Spree
  class AssembliesPart < ActiveRecord::Base
    belongs_to :assembly, class_name: "Spree::Variant",
                          foreign_key: "assembly_id",
                          touch: true

    belongs_to :part, class_name: "Spree::Variant", foreign_key: "part_id"

    delegate :name, :sku, :total_on_hand, to: :part

    after_create :set_master_unlimited_stock

    validate :assembly_can_not_be_part

    def assembly_can_not_be_part
      if part.assembly?
        errors.add(:base, "Assembly can't be part!")
      elsif assembly.part?
        errors.add(:base, "Part can't be assembly!")
      end
    end

    def self.get(assembly_id, part_id)
      find_or_initialize_by(assembly_id: assembly_id, part_id: part_id)
    end

    def options_text
      if variant_selection_deferred?
        Spree.t(:user_selectable)
      else
        part.options_text
      end
    end

    private

    def set_master_unlimited_stock
      if part.product.variants.any?
        part.product.master.update_attribute :track_inventory, false
      end
    end
  end
end
