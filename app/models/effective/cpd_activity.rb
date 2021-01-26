module Effective
  class CpdActivity < ActiveRecord::Base
    belongs_to :cpd_cycle
    belongs_to :cpd_category

    has_rich_text :body
    log_changes(to: :cpd_cycle) if respond_to?(:log_changes)

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
    validates :amount_label, presence: true

    validates :max_credits_per_cycle, numericality: { min: 0, allow_nil: true }
    validates :max_cycles_can_carry_forward, numericality: { min: 0, allow_nil: true }

    def to_s
      title.presence || 'category'
    end

  end
end
