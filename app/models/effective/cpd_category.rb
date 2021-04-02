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

    scope :deep, -> { with_rich_text_body.includes(:cpd_activities) }
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

  # You can pass a statement or a cycle...
  # def rule_for(obj)
  #   cycle_id = case obj
  #     when Cycle      ; obj.id
  #     when Statement  ; obj.cycle_id
  #     when Integer    ; obj
  #   end

  #   rules.find { |rule| rule.cycle_id <= cycle_id }
  # end

  end
end
