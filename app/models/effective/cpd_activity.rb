module Effective
  class CpdActivity < ActiveRecord::Base
    belongs_to :cpd_category

    has_rich_text :body
    log_changes(to: :cpd_category) if respond_to?(:log_changes)

    # has_many :rules, -> { order(cycle_id: :desc) }, as: :ruleable, dependent: :delete_all
    # accepts_nested_attributes_for :rules, allow_destroy: true

    effective_resource do
      title     :string
      position  :integer

      # The formula can include amount and amount2
      # This is the description of the amount unit
      amount_label          :string # 'hours of committee work', 'hours or work'
      amount2_label         :string # 'CEUs'

      # Whether the user must attach supporting documents
      requires_upload_file  :boolean

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(:cpd_category) }
    scope :sorted, -> { order(:position) }

    before_validation(if: -> { cpd_category.present? }) do
      self.position ||= (cpd_category.cpd_activities.map(&:position).compact.max || -1) + 1
    end

    validates :title, presence: true
    validates :position, presence: true

    def to_s
      title.presence || 'activity'
    end

  end
end
