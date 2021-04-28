require 'test_helper'

class CpdAuditLevelsTest < ActiveSupport::TestCase

  test 'create a valid audit level' do
    cpd_audit_level = build_effective_cpd_audit_level()
    assert cpd_audit_level.valid?
  end

end
