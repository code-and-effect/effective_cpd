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
    scope :unavailable, -> { where(unavailable: true) }

    #validates :cpd_cycle_id, uniqueness: { scope: [:ruleable_id, :ruleable_type] }
    validates :credit_description, presence: true
    validates :max_credits_per_cycle, numericality: { greater_than: 0, allow_nil: true }
    validates :max_cycles_can_carry_forward, numericality: { greater_than: 0, allow_nil: true }

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

    # The formula is determined by the cpd_activity's amount_label and amount2_label presence
    validate(if: -> { formula.present? && activity? }) do
      amount = formula.gsub('amount2', '').include?('amount')
      amount2 = formula.include?('amount2')

      cpd_activity = ruleable

      if cpd_activity.amount_label.present? && cpd_activity.amount2_label.present?
        self.errors.add(:formula, 'must include "amount"') unless amount.present?
        self.errors.add(:formula, 'must include "amount2"') unless amount2.present?
      elsif cpd_activity.amount_label.present?
        self.errors.add(:formula, 'must include "amount"') unless amount.present?
        self.errors.add(:formula, 'must not include "amount2"') if amount2.present?
      elsif cpd_activity.amount2_label.present?
        self.errors.add(:formula, 'must include "amount2"') unless amount2.present?
        self.errors.add(:formula, 'must not include "amount"') if amount.present?
      else
        self.errors.add(:formula, 'must not include "amount"') if amount.present?
        self.errors.add(:formula, 'must not include "amount2"') if amount2.present?
      end
    end

    def to_s
      formula.presence || 'category'
    end

    def activity?
      ruleable.kind_of?(CpdActivity)
    end

    def category?
      ruleable.kind_of?(CpdCategory)
    end

    def score(cpd_statement_activity:)
      raise('cpd_cycles must match') unless cpd_statement_activity.cpd_statement.cpd_cycle_id == cpd_cycle_id
      raise('cpd_activities must match') unless cpd_statement_activity.cpd_activity_id == ruleable_id

      return cpd_statement_activity.carry_over if cpd_statement_activity.is_carry_over?

      equation = formula
        .gsub('amount2', cpd_statement_activity.amount2.to_s)
        .gsub('amount', cpd_statement_activity.amount.to_s)

      eval(equation).to_i
    end

  end
end
