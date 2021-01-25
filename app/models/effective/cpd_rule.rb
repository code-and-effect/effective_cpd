module Effective
  class CpdRule < ActiveRecord::Base
    belongs_to :cpd_cycle
    belongs_to :ruleable, polymorphic: true # Either a CpdActivity or CpdCategory

    effective_resource do
      description             :text

      # (amount / 15) or (30) or (amount * 2)
      formula                 :string

      # The maximum credits per cycle a statement may have with activities of this type. Nil for no limit.
      max_credits_per_cycle   :integer

      # Maximum number of cycles can carry forward
      max_cycles_can_carry_forward  :integer

      timestamps
    end

    scope :deep, -> { includes(:cpd_cycle) }
    scope :sorted, -> { order(:id) }

    validates :description, presence: true
    validates :max_cycles_can_carry_forward, presence: true, numericality: { min: 0 }
    validates :formula, presence: true

    validates :cycle_id, uniqueness: {
      scope: [:ruleable_type, :ruleable_id], message: 'already has a rule for this cycle'
    }

    #validates :formula, presence true :if => Proc.new { |cycle_rule| cycle_rule.ruleable.kind_of?(Activity) }

    def to_s
      description.presence || 'rule'
    end

  end
end
