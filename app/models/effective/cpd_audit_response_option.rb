module Effective
  class CpdAuditResponseOption < ActiveRecord::Base
    belongs_to :cpd_audit_response
    belongs_to :cpd_audit_level_question_option
  end
end
