module Effective
  class CpdAuditReviewItem < ActiveRecord::Base
    belongs_to :cpd_audit_review
    belongs_to :item, polymorphic: true # CpdAuditResponse or CpdStatementActivity

    log_changes(to: :cpd_audit_review) if respond_to?(:log_changes)

    effective_resource do
      recommendation            :string
      comments                  :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit_review, :cpd_audit_level_question) }
    scope :sorted, -> { order(:id) }

    validates :item_id, presence: true, uniqueness: { scope: [:cpd_audit_review_id, :item_type] }

    def to_s
      recommendation.presence || 'cpd audit review item'
    end

    def available_recommendations
      ['Accept', 'Reject']
    end

    def accepted?
      recommendation == 'Accept'
    end

    def rejected?
      recommendation == 'Reject'
    end

  end
end
