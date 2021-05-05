# EffectiveCpdUser
#
# Mark your user model with effective_cpd_user to get a few helpers
# And user specific point required scores

module EffectiveCpdUser
  extend ActiveSupport::Concern

  module Base
    def effective_cpd_user
      include ::EffectiveCpdUser
    end
  end

  included do
    has_many :cpd_statements, -> { Effective::CpdStatement.sorted }, class_name: 'Effective::CpdStatement'
    has_many :cpd_audits, -> { Effective::CpdAudit.sorted }, inverse_of: :user, class_name: 'Effective::CpdAudit'
    has_many :cpd_audit_reviews, -> { Effective::CpdAuditReview.sorted }, inverse_of: :user, class_name: 'Effective::CpdAuditReview'
  end

  def cpd_statement_required_score(cpd_statement)
    nil
  end

  module ClassMethods
    def effective_cpd_user?; true; end
  end

end
