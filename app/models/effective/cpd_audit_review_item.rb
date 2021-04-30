module Effective
  class CpdAuditReviewItem < ActiveRecord::Base
    belongs_to :cpd_audit_review
    belongs_to :item, polymorphic: true # CpdAuditResponse or CpdStatementActivity

    if respond_to?(:log_changes)
      log_changes(to: :cpd_audit_review)
    end

    effective_resource do
      recommendation            :string
      comments                  :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit_review, :item) }
    scope :sorted, -> { order(:id) }

    validates :recommendation, presence: true
    validates :item_id, presence: true, uniqueness: { scope: [:cpd_audit_review_id, :item_type] }

    validate(if: -> { cpd_audit_review.present? && recommendation.present? }) do
      unless cpd_audit_review.cpd_audit_level.determinations.include?(recommendation)
        self.errors.add(:recommendation, 'must exist in this audit level')
      end
    end

    def to_s
      recommendation.presence || 'cpd audit review item'
    end

  end
end
