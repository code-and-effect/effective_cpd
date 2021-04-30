module Effective
  class CpdActivity < ActiveRecord::Base
    belongs_to :cpd_category

    has_rich_text :body

    if respond_to?(:log_changes)
      log_changes(to: :cpd_category, except: [:cpd_statement_activities])
    end

    #has_many :rules, class_name: 'Effective::CpdRule', as: :ruleable
    has_many :cpd_statement_activities

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

    before_destroy do
      if (count = cpd_statement_activities.length) > 0
        raise("#{count} statement activities belong to this activity")
      end
    end

    def to_s
      title.presence || 'activity'
    end

    def amount_static?
      amount_label.blank? && amount2_label.blank?
    end

  end
end
