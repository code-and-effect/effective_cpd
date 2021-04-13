require 'test_helper'

class CpdScorerTest < ActiveSupport::TestCase
  test 'complete statement points' do
    cpd_statement = create_scoreable_cpd_statement!

    assert_equal 7, cpd_statement.cpd_statement_activities.map(&:cpd_category_id).uniq.length
    assert_equal 25, cpd_statement.cpd_statement_activities.map(&:cpd_activity_id).uniq.length

    assert_equal 330, cpd_statement.cpd_statement_activities.map(&:score).sum
    assert_equal 330, cpd_statement.score
  end

  test 'roll forward' do
    user = create_user!

    # First Statement
    first = create_scoreable_cpd_statement!(user: user)
    assert_equal 330, first.score

    assert_equal 25, first.cpd_statement_activities.length
    assert first.cpd_statement_activities.all? { |a| a.carry_over.nil? }
    assert first.cpd_statement_activities.all? { |a| a.original.nil? }

    assert_equal 410, first.cpd_statement_activities.sum(&:carry_forward)
    assert_equal 330, first.cpd_statement_activities.sum(&:score)
    assert_equal [20, 20, 20, 15, 15, 30, 210], first.score_per_category.values
    assert_equal 410, first.carry_forward

    # Second Statement
    second = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 80, second.score

    assert_equal 13, second.cpd_statement_activities.length
    assert second.cpd_statement_activities.all? { |a| a.original.present? && a.original.cpd_statement.cpd_cycle == first.cpd_cycle }
    assert second.cpd_statement_activities.all? { |a| a.carry_over.present? }

    assert_equal 410, second.cpd_statement_activities.sum(&:carry_over)
    assert_equal 80, second.cpd_statement_activities.sum(&:score)
    assert_equal [20, 15, 15, 30], second.score_per_category.values
    assert_equal 330, second.cpd_statement_activities.sum(&:carry_forward)

    # Third Statement
    third = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 45, third.score

    assert_equal 7, third.cpd_statement_activities.length
    assert third.cpd_statement_activities.all? { |a| a.original.present? && a.original.cpd_statement.cpd_cycle == first.cpd_cycle }
    assert third.cpd_statement_activities.all? { |a| a.carry_over.present? }

    assert_equal 330, third.cpd_statement_activities.sum(&:carry_over)
    assert_equal 45, third.cpd_statement_activities.sum(&:score)
    assert_equal [15, 30], third.score_per_category.values
    assert_equal 0, third.cpd_statement_activities.sum(&:carry_forward)

    # Fourth Statement
    fourth = create_scoreable_cpd_statement!(user: user, continue: true)
    assert_equal 0, fourth.score
    assert_equal 0, fourth.cpd_statement_activities.length
  end

  test 'cascading delete' do
    user = create_user!

    # First Statement
    first = create_scoreable_cpd_statement!(user: user)
    second = create_scoreable_cpd_statement!(user: user, continue: true)
    third = create_scoreable_cpd_statement!(user: user, continue: true)

    assert_equal 330, first.score
    assert_equal 80, second.score
    assert_equal 45, third.score

    second.cpd_statement_activities.each_with_index { |csa, index| csa.destroy! if index > 2 }
    Effective::CpdScorer.new(user: user).score!

    first.reload
    second.reload
    third.reload

    assert_equal 330, first.score
    assert_equal 80, second.score
    assert_equal 45, third.score
  end

end
