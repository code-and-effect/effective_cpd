module Effective
  class CpdCategory < ActiveRecord::Base
    belongs_to :cpd_cycle

    has_rich_text :body
    log_changes(to: :cpd_cycle) if respond_to?(:log_changes)

    effective_resource do
      title     :string
      position  :integer

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(:cpd_cycle) }
    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_cycle.present? }) do
      self.position ||= (cpd_cycle.cpd_categories.map { |obj| obj.position }.compact.max || -1) + 1
    end

    validates :cpd_cycle, presence: true

    validates :title, presence: true
    validates :position, presence: true

    def to_s
      title.presence || 'category'
    end

  end
end
