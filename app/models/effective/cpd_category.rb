module Effective
  class CpdCategory < ActiveRecord::Base
    belongs_to :cpd_cycle

    has_rich_text :body
    log_changes(to: :cpd_cycle) if respond_to?(:log_changes)

    has_many :cpd_activities, -> { order(:position) }, inverse_of: :cpd_category, dependent: :destroy
    accepts_nested_attributes_for :cpd_activities, allow_destroy: true

    effective_resource do
      title     :string
      position  :integer

      # The maximum credits per cycle a statement. Nil for no limit
      max_credits_per_cycle   :integer

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(:cpd_cycle) }
    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_cycle.present? }) do
      self.position ||= (cpd_cycle.cpd_categories.map(&:position).compact.max || -1) + 1
    end

    validates :cpd_cycle, presence: true

    validates :title, presence: true
    validates :position, presence: true
    validates :body, presence: true
    validates :max_credits_per_cycle, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    def to_s
      title.presence || 'category'
    end

  end
end
