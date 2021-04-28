require 'test_helper'

class CpdAuditTest < ActiveSupport::TestCase

  test 'create a valid audit' do
    cpd_audit = build_effective_cpd_audit()
    assert cpd_audit.valid?

    assert_equal 2, cpd_audit.cpd_audit_reviews.length
  end

end
