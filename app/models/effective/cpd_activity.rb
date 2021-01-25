module Effective
  class CpdActivity < ActiveRecord::Base
    belongs_to :cpd_cycle
    belongs_to :cpd_category

    log_changes(to: :cpd_cycle) if respond_to?(:log_changes)

    effective_resource do
      title     :string

      amount_description    :string # 'hours of committee work', 'hours or work'
      amount2_description   :string # 'CEUs'

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(:cpd_cycle) }
    scope :sorted, -> { order(:title) }

    validates :cpd_cycle, presence: true
    validates :cpd_category, presence: true

    validates :title, presence: true
    validates :amount_description, presence: true

    def to_s
      title.presence || 'category'
    end

  end
end
