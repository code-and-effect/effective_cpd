require 'test_helper'

class CpdCycleTest < ActiveSupport::TestCase

  test 'create a valid cycle' do
    cpd_cycle = build_effective_cpd_cycle()
    assert cpd_cycle.valid?
  end

end
