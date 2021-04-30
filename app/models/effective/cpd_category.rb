module Effective
  class CpdCategory < ActiveRecord::Base
    has_rich_text :body

    has_many :cpd_activities, -> { order(:position) }, inverse_of: :cpd_category, dependent: :destroy
    accepts_nested_attributes_for :cpd_activities, allow_destroy: true

    has_many :rules, class_name: 'Effective::CpdRule', as: :ruleable
    has_many :cpd_statement_activities

    if respond_to?(:log_changes)
      log_changes(except: [:rules, :cpd_statement_activities])
    end

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

    before_destroy do
      if (count = cpd_statement_activities.length) > 0
        raise("#{count} statement activities belong to this category")
      end
    end

    def to_s
      title.presence || 'category'
    end

  end
end
