module Effective
  class CpdSpecialRule < ActiveRecord::Base
    belongs_to :cpd_cycle

    has_many :cpd_special_rule_mates, dependent: :destroy, inverse_of: :cpd_special_rule
    has_many :cpd_rules, -> { CpdRule.sorted }, through: :cpd_special_rule_mates

    if respond_to?(:log_changes)
      log_changes
    end

    CATEGORIES = ['cumulative max credits']

    effective_resource do
      category  :string # Special rule tyoes

      # For cumulative max credits
      max_credits_per_cycle :integer

      timestamps
    end

    scope :deep, -> { includes(:cpd_special_rule_mates, cpd_rules: [:ruleable]) }
    scope :sorted, -> { order(:id) }

    before_validation do
      self.category ||= CATEGORIES.first
    end

    validates :category, presence: true, inclusion: { in: CATEGORIES }

    with_options(if: -> { cumulative_max_credits? }) do
      validates :max_credits_per_cycle, presence: true, numericality: { greater_than: 0 }
    end

    def to_s
      if cumulative_max_credits?
        "Cumulative max #{max_credits_per_cycle} credits"
      else
        'cpd special rule'
      end
    end

    def cumulative_max_credits?
      category == 'cumulative max credits'
    end

  end
end
