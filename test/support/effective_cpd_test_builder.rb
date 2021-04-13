module EffectiveCpdTestBuilder
  def create_effective_cpd_cycle!
    build_effective_cpd_cycle.tap { |cpd_cycle| cpd_cycle.save! }
  end

  def build_effective_cpd_cycle
    cpd_cycle = Effective::CpdCycle.new(
      title: 'Cpd Cycle',
      start_at: Time.zone.now,
      end_at: Time.zone.now.end_of_day,
      required_score: nil,
    )

    cpd_cycle.all_steps_content = 'All Steps Content'
    cpd_cycle
  end

  def create_effective_cpd_statement!(cpd_cycle: nil, user: nil)
    build_effective_cpd_statement(cpd_cycle: cpd_cycle, user: user).tap { |cpd_statement| cpd_statement.save! }
  end

  def build_effective_cpd_statement(cpd_cycle: nil, user: nil)
    cpd_cycle ||= create_effective_cpd_cycle!
    user ||= create_user!

    cpd_statement = Effective::CpdStatement.new(
      cpd_cycle: cpd_cycle,
      user: user
    )
  end

  # Create a StatementActivity for each activity.
  def create_scoreable_cpd_statement!(cpd_cycle: nil, user: nil, amount: 10, amount2: 10, continue: false)
    cpd_statement = create_effective_cpd_statement!(cpd_cycle: cpd_cycle, user: user)

    unless continue
      Effective::CpdCategory.sorted.all.each do |category|
        category.cpd_activities.each do |activity|
          csa = cpd_statement.cpd_statement_activities.create!(
            cpd_category: category,
            cpd_activity: activity,
            amount: (amount if activity.amount_label.present?),
            amount2: (amount2 if activity.amount2_label.present?),
          )
        end
      end
    end

    Effective::CpdScorer.new(user: cpd_statement.user).score!
    cpd_statement.reload

    cpd_statement
  end

  def create_user!
    build_user.tap { |user| user.save! }
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

end
