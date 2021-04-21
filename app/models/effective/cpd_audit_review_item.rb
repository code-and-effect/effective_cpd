module Effective
  class CpdAuditReviewItem < ActiveRecord::Base
    belongs_to :cpd_audit_review
    belongs_to :cpd_audit_question

    log_changes(to: :cpd_audit_review) if respond_to?(:log_changes)

    effective_resource do
      recommendation            :string
      comments                  :text

      timestamps
    end

    scope :deep, -> { includes(:cpd_audit_review, :cpd_audit_question) }

    validates :cpd_audit_question_id, presence: true, uniqueness: { scope: [:cpd_audit_review_id] }

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
