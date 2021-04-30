require 'test_helper'

class CpdAuditLevelsTest < ActiveSupport::TestCase

  test 'create a valid audit level' do
    cpd_audit_level = create_effective_cpd_audit_level!()
    assert cpd_audit_level.valid?

    assert_equal 2, cpd_audit_level.cpd_audit_level_sections.length
    assert_equal 4, cpd_audit_level.cpd_audit_level_questions.length
  end

end
