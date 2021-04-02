module Effective
  class CpdRule < ActiveRecord::Base
    belongs_to :cpd_cycle
    belongs_to :ruleable, polymorphic: true # Activity or Category

    log_changes(to: :cpd_cycle) if respond_to?(:log_changes)

    # Only permit the words amount, amount2 and any charater 0-9 + - / * ( )
    INVALID_FORMULA_CHARS = /[^0-9\+\-\/\*\(\)]/

    effective_resource do
      # A plaintext description of the formula
      # For a Category: A maximum of 35 PDHs/year may be claimed in the Contributions to Knowledge category
      # For a Activity: 15 hours of work equals 1 credit
      credit_description :text

      # The maximum credits per cycle a statement. Nil for no limit
      max_credits_per_cycle   :integer

      # (amount / 15) or (30) or (amount * 2) or (amount + (amount2 * 10))
      formula   :string

      # Maximum number of cycles can carry forward
      max_cycles_can_carry_forward  :integer

      # Cannot be entered in this cycle
      unavailable     :boolean

      timestamps
    end

    scope :deep, -> { includes(:cpd_cycle, :ruleable) }
    scope :categories, -> { where(ruleable_type: 'Effective::CpdCategory') }
    scope :activities, -> { where(ruleable_type: 'Effective::CpdActivity') }

    validates :cpd_cycle_id, uniqueness: { scope: [:ruleable_id, :ruleable_type] }
    validates :credit_description, presence: true
    validates :max_credits_per_cycle, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :max_cycles_can_carry_forward, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    validates :formula, presence: true, if: -> { activity? }
    validates :formula, absence: true, if: -> { category? }

    validate(if: -> { formula.present? }) do
      if formula.gsub('amount2', '').gsub('amount', '').gsub(' ', '').match(INVALID_FORMULA_CHARS).present?
        self.errors.add(:formula, "may only contain amount, amount2 and 0-9 + - / * ( ) characters")
      else
        begin
          score(amount: 0, amount2: 0)
        rescue Exception => e
          self.errors.add(:formula, e.message)
        end
      end
    end

    # validates :amount_label, if: -> { formula.to_s.gsub('amount2', '').include?('amount') },
    #   presence: { message: 'must be present when used in formula' }

    # validates :amount_label, unless: -> { formula.to_s.gsub('amount2', '').include?('amount') },
    #   absence: { message: 'must be blank unless used in formula' }

    # validates :amount2_label, if: -> { formula.to_s.include?('amount2') },
    #   presence: { message: 'must be present when used in formula' }

    # validates :amount2_label, unless: -> { formula.to_s.include?('amount2') },
    #   absence: { message: 'must be blank unless used in formula' }

    def to_s
      formula.presence || 'category'
    end

    def activity?
      ruleable.kind_of?(CpdActivity)
    end

    def category?
      ruleable.kind_of?(CpdCategory)
    end

    def score(amount:, amount2:)
      equation = formula.to_s.gsub('amount2', amount2.to_s).gsub('amount', amount.to_s)
      eval(equation).to_i
    end

  end
end
