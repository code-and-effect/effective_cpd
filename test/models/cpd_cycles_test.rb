require 'test_helper'

class CpdCycleTest < ActiveSupport::TestCase

  test 'create a valid cycle' do
    cpd_cycle = build_effective_cpd_cycle()
    assert cpd_cycle.valid?
  end

  test 'build from latest' do
    existing = build_effective_cpd_cycle()
    existing.all_steps_content = "Test 123"
    existing.required_score = 100
    existing.save!

    cpd_cycle = Effective::CpdCycle.create!(
      title: 'Second CPD Cycle',
      start_at: Time.zone.now,
      end_at: Time.zone.now.end_of_day
    )

    assert_equal 100, cpd_cycle.required_score

    assert cpd_cycle.all_steps_content.present?
    assert cpd_cycle.all_steps_content.to_s.include?('Test 123')

    assert cpd_cycle.cpd_categories.present?
    assert_equal existing.cpd_categories.length, cpd_cycle.cpd_categories.length

    assert_equal Effective::CpdActivity.where(cpd_cycle: existing).count, Effective::CpdActivity.where(cpd_cycle: cpd_cycle).count
  end

end
