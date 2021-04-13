module Effective
  class CpdStatement < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_cycle
    belongs_to :user, polymorphic: true

    has_many :cpd_statement_activities, -> { order(:id) }, inverse_of: :cpd_statement, dependent: :destroy
    accepts_nested_attributes_for :cpd_statement_activities

    has_many_attached :files

    acts_as_tokened

    acts_as_wizard(
      start: 'Start',
      activities: 'Enter Activities',
      agreements: 'Sign Agreements',
      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    effective_resource do
      # Acts as tokened
      token                  :string, permitted: false

      # Acts as Wizard
      wizard_steps           :text, permitted: false

      # More fields
      completed_at           :datetime, permitted: false

      # The score for this statement
      score                   :integer

      timestamps
    end

    scope :deep, -> { includes(:cpd_cycle, :user, cpd_statement_activities: [:cpd_activity]) }
    scope :completed, -> { where.not(completed_at: nil) }
    scope :sorted, -> { order(:cpd_cycle_id) }

    before_validation(if: -> { new_record? }) do
      self.user ||= current_user
      self.score ||= 0
    end

    validate(if: -> { completed? && cpd_cycle.required_score.present? }) do
      min = cpd_cycle.required_score
      self.errors.add(:score, "must be #{min} or greater to submit statement") if score < min
    end

    def to_s
      persisted? ? "#{id}-#{cpd_cycle}" : 'statement'
    end

    # This is the review step where they click Submit Ballot
    def submit!
      wizard_steps[:complete] ||= Time.zone.now
      self.completed_at ||= Time.zone.now

      save!
    end

    def completed?
      completed_at.present?
    end

    def carry_forward
      cpd_statement_activities.sum { |activity| activity.carry_forward.to_i }
    end

    # {category1 => 20, category2 => 15}
    def score_per_category
      @score_per_category ||= Hash.new(0).tap do |scores|
        cpd_statement_activities.each { |activity| scores[activity.cpd_category_id] += activity.score.to_i }
      end
    end

  end
end
