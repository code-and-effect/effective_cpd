module Effective
  class CpdScorer
    include EffectiveCpdHelper

    def initialize(user:)
      @cycles = CpdCycle.sorted.all
      @statements = CpdStatement.where(user: user).sorted.all
    end

    def score!
      @statements.each_with_index do |statement, index|
        prev_statement = @statements[index-1] if index > 0

        Array(prev_statement&.cpd_statement_activities).each do |activity|
          if activity.marked_for_destruction? # Cascade this down the line
            statement.cpd_statement_activities.each { |a| a.mark_for_destruction if a.original == activity }
          end

          if can_carry_forward?(activity, statement.cpd_cycle)
            update_or_create_carry_forward_activity(activity, statement)
          else
            delete_carry_forward_activity(activity, statement)
          end
        end

        score_statement(statement)
      end

      save!
    end

    protected

    def save!
      CpdStatement.transaction do
        @statements.each { |statement| statement.save! }; true
      end
    end

    def score_statement(statement)
      cycle = statement.cpd_cycle

      # Reset the current carry_forwards and messages
      statement.cpd_statement_activities.each do |activity|
        activity.carry_forward = nil
        activity.reduced_messages.clear
      end

      # This scores and enforces CycleActivity.max_credits_per_cycle
      statement.cpd_statement_activities.group_by(&:cpd_activity).each do |cpd_activity, activities|
        rule = cycle.rule_for(cpd_activity)
        max_credits_per_cycle = rule.max_credits_per_cycle

        activities.each do |activity|
          next if activity.marked_for_destruction?

          activity.score = rule.score(cpd_statement_activity: activity)
          activity.max_score = activity.score # Hack for Category maximums below

          next if max_credits_per_cycle == nil

          max_credits_per_cycle -= activity.score  # Counting down...

          if max_credits_per_cycle < 0
            activity.carry_forward = [0 - max_credits_per_cycle, activity.score].min
            activity.reduced_messages["activity_#{cpd_activity.id}"] = "You have reached the maximum of #{rule.max_credits_per_cycle}/#{cpd_cycle_label} for this type of activity"
            activity.score = [activity.score + max_credits_per_cycle, 0].max
          end
        end
      end

      # This enforced CycleCategory.max_credits_per_cycle
      statement.cpd_statement_activities.group_by(&:cpd_category).each do |cpd_category, activities|
        rule = cycle.rule_for(cpd_category)
        max_credits_per_cycle = rule.max_credits_per_cycle

        next if max_credits_per_cycle == nil

        activities.each do |activity|
          next if activity.marked_for_destruction?

          max_credits_per_cycle -= activity.score   # We're already scored. Counting down...

          if max_credits_per_cycle < 0
            activity.score = [activity.score + max_credits_per_cycle, 0].max
            activity.carry_forward = activity.max_score - activity.score
            activity.reduced_messages["category_#{cpd_category.id}"] = "You have reached the maximum of #{rule.max_credits_per_cycle}/#{cpd_cycle_label} for activities in the #{cpd_category} category"
          end
        end
      end

      # This enforces the max_cycles_can_carry_forward logic
      # If an Activity cannot be carried forward another cycle, its carry_forward should be 0
      next_cycle = @cycles[@cycles.index(cycle) + 1]

      statement.cpd_statement_activities.each do |activity|
        unless can_carry_forward?(activity, next_cycle)
          activity.carry_forward = 0
          activity.reduced_messages['max_cycles_can_carry_forward'] = "This activity cannot be carried forward any further"
        end
      end

      # Finally set the score from the sum of activitiy scores
      statement.score = statement.cpd_statement_activities.map { |activity| activity.marked_for_destruction? ? 0 : activity.score }.sum
    end

    def can_carry_forward?(activity, to_cycle = nil) # This is a StatementActivity being passed
      return false if (activity.carry_forward == 0 || activity.marked_for_destruction?)

      from_cycle = @cycles.find { |cycle| cycle.id == (activity.original || activity).cpd_statement.cpd_cycle_id }
      max_cycles_can_carry_forward = from_cycle.rule_for(activity.cpd_activity).max_cycles_can_carry_forward

      return true if max_cycles_can_carry_forward.blank?

      cycles_carried = (@cycles.index(to_cycle) || @cycles.size) - @cycles.index(from_cycle)
      cycles_carried <= max_cycles_can_carry_forward
    end

    def update_or_create_carry_forward_activity(activity, statement)
      existing = statement.cpd_statement_activities.find { |a| a.original == (activity.original || activity) }
      existing ||= statement.cpd_statement_activities.build()

      existing.assign_attributes(
        cpd_category: activity.cpd_category,
        cpd_activity: activity.cpd_activity,
        amount: activity.amount,
        amount2: activity.amount2,
        description: activity.description
      )

      existing.assign_attributes(carry_over: activity.carry_forward, original: activity.original || activity)
      existing
    end

    def delete_carry_forward_activity(activity, statement)
      existing = statement.cpd_statement_activities.find { |a| a.original == (activity.original || activity) }
      existing&.mark_for_destruction
    end

  end
end
