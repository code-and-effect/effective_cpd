require 'test_helper'

class CpdStatementsTest < ActiveSupport::TestCase

  test 'create a valid statement' do
    cpd_statement = build_effective_cpd_statement()
    assert cpd_statement.valid?

    assert_equal 0, cpd_statement.score
  end

  test 'must have required score to submit' do
    cpd_statement = build_effective_cpd_statement()
    cpd_statement.cpd_cycle.update!(required_score: 5)

    assert cpd_statement.valid?

    refute (cpd_statement.submit! rescue false)
    assert cpd_statement.errors[:score].present?
    assert cpd_statement.errors[:score].first.include?('5')
  end

  test 'can score and submit a statement' do
    cpd_statement = create_effective_cpd_statement!()
    cpd_statement.cpd_cycle.update!(required_score: 5)

    cpd_category = Effective::CpdCategory.first
    cpd_activity = cpd_category.cpd_activities.first

    cpd_statement.cpd_statement_activities.create!(
      cpd_activity: cpd_activity, cpd_category: cpd_category, amount: 5, description: 'test'
    )

    Effective::CpdScorer.new(user: cpd_statement.user).score!
    cpd_statement.reload

    assert_equal 5, cpd_statement.score
    assert_equal 5, cpd_statement.cpd_statement_activities.first.score
    assert cpd_statement.submit!
  end

end
