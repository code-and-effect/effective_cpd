module Effective
  class CpdActivity < ActiveRecord::Base
    belongs_to :cpd_cycle
    belongs_to :cpd_category

    has_rich_text :body
    log_changes(to: :cpd_cycle) if respond_to?(:log_changes)

    # Only permit the words amount, amount2 and any charater 0-9 + - / * ( )
    INVALID_FORMULA_CHARS = /[^0-9\+\-\/\*\(\)]/

    effective_resource do
      title     :string
      position  :integer

      # (amount / 15) or (30) or (amount * 2) or (amount + (amount2 * 10))
      formula   :string

      # The formula can include amount and amount2
      # This is the description of the amount unit
      amount_label          :string # 'hours of committee work', 'hours or work'
      amount2_label         :string # 'CEUs'

      # Whether the user must attach supporting documents
      requires_upload_file  :boolean

      # The maximum credits per cycle a statement. Nil for no limit
      max_credits_per_cycle   :integer

      # Maximum number of cycles can carry forward
      max_cycles_can_carry_forward  :integer

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(:cpd_cycle, :cpd_category) }
    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_category.present? }) do
      self.position ||= (cpd_category.cpd_activities.map { |obj| obj.position }.compact.max || -1) + 1
    end

    before_validation(if: -> { cpd_category.present? }) do
      self.cpd_cycle ||= cpd_category.cpd_cycle
    end

    validates :cpd_cycle, presence: true
    validates :cpd_category, presence: true

    validates :title, presence: true
    validates :formula, presence: true
    validates :position, presence: true

    validates :max_credits_per_cycle, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :max_cycles_can_carry_forward, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    validates :amount_label, if: -> { formula.to_s.gsub('amount2', '').include?('amount') },
      presence: { message: 'must be present when used in formula' }

    validates :amount_label, unless: -> { formula.to_s.gsub('amount2', '').include?('amount') },
      absence: { message: 'must be blank unless used in formula' }

    validates :amount2_label, if: -> { formula.to_s.include?('amount2') },
      presence: { message: 'must be present when used in formula' }

    validates :amount2_label, unless: -> { formula.to_s.include?('amount2') },
      absence: { message: 'must be blank unless used in formula' }

    validate(if: -> { formula.present? }) do
      if formula.gsub('amount2', '').gsub('amount', '').gsub(' ', '').match(INVALID_FORMULA_CHARS).present?
        self.errors.add(:formula, "may only contain amount, amount2 and 0-9 + - / * ( ) characters")
      else
        begin
          score(amount: 0, amount2: 0, skip_rescue: true)
        rescue Exception => e
          self.errors.add(:formula, e.message)
        end
      end
    end

    def to_s
      title.presence || 'activity'
    end

    def score(amount:, amount2:, skip_rescue: false)
      equation = formula.to_s.gsub('amount2', amount2.to_s).gsub('amount', amount.to_s)
      skip_rescue ? eval(equation).to_i : (eval(equation).to_i rescue 0)
    end

  end
end
