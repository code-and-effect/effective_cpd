require 'test_helper'

class CpdAuditReviewsTest < ActiveSupport::TestCase

  test 'submitting all cpd audit reviews mark the audit as reviewed' do
    cpd_audit = build_effective_cpd_audit()
    cpd_audit.submit!

    cpd_audit_reviews = cpd_audit.cpd_audit_reviews
    assert_equal 2, cpd_audit_reviews.length

    cpd_audit_reviews.first.submit!
    cpd_audit.reload
    assert cpd_audit.submitted?

    cpd_audit_reviews.last.submit!
    cpd_audit.reload
    assert cpd_audit.reviewed?
  end

end
