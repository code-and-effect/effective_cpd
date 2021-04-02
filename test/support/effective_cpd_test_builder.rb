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
