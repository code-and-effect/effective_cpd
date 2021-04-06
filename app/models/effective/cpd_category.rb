module Effective
  class CpdCategory < ActiveRecord::Base
    has_rich_text :body
    log_changes if respond_to?(:log_changes)

    has_many :cpd_activities, -> { order(:position) }, inverse_of: :cpd_category, dependent: :destroy
    accepts_nested_attributes_for :cpd_activities, allow_destroy: true

    # has_many :rules, -> { order(cycle_id: :desc) }, as: :ruleable, dependent: :delete_all
    # accepts_nested_attributes_for :rules, allow_destroy: true

    effective_resource do
      title     :string
      position  :integer

      timestamps
    end

    scope :deep, -> { with_rich_text_body.includes(cpd_activities: [:rich_text_body]) }
    scope :sorted, -> { order(:position) }

    before_validation do
      self.position ||= (CpdCategory.all.maximum(:position) || -1) + 1
    end

    validates :title, presence: true
    validates :position, presence: true
    validates :body, presence: true

    def to_s
      title.presence || 'category'
    end

  end
end
