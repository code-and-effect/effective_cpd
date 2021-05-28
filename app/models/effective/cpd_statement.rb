module Effective
  class CpdStatement < ActiveRecord::Base
    attr_accessor :current_user
    attr_accessor :current_step

    belongs_to :cpd_cycle
    belongs_to :user, polymorphic: true

    has_many :cpd_statement_activities, -> { order(:id) }, inverse_of: :cpd_statement, dependent: :destroy
    accepts_nested_attributes_for :cpd_statement_activities

    has_many_attached :files

    if respond_to?(:log_changes)
      log_changes(except: [:wizard_steps])
    end

    acts_as_tokened

    acts_as_wizard(
      start: 'Start',
      activities: 'Enter Activities',
      agreements: 'Sign Agreements',
      submit: 'Confirm & Submit',
      complete: 'Complete'
    )

    effective_resource do
      score                   :integer

      confirm_read            :boolean
      confirm_factual         :boolean
      confirm_readonly        :boolean

      submitted_at            :datetime, permitted: false

      # Acts as tokened
      token                  :string, permitted: false

      # Acts as Wizard
      wizard_steps           :text, permitted: false

      timestamps
    end

    scope :deep, -> { includes(:cpd_cycle, :user, cpd_statement_activities: [:files_attachments, :cpd_category, :original, cpd_activity: [:rich_text_body]]) }
    scope :sorted, -> { order(:cpd_cycle_id) }

    scope :draft, -> { where(submitted_at: nil) }
    scope :completed, -> { where.not(submitted_at: nil) }

    before_validation(if: -> { new_record? }) do
      self.user ||= current_user
      self.score ||= 0
    end

    validate(if: -> { completed? }) do
      min = required_score()
      self.errors.add(:score, "must be #{min} or greater to submit a statement") if score < min
    end

    with_options(if: -> { current_step == :agreements }) do
      validates :confirm_read, acceptance: true
      validates :confirm_factual, acceptance: true
    end

    with_options(if: -> { current_step == :submit}) do
      validates :confirm_readonly, acceptance: true
    end

    def to_s
      cpd_cycle.present? ? "#{cpd_cycle} Statement" : 'statement'
    end

    # This is the review step where they click Submit Ballot
    def submit!
      wizard_steps[:complete] ||= Time.zone.now

      update!(submitted_at: Time.zone.now)
    end

    # Called by admin only. This is an exceptional action
    def unsubmit!
      update!(wizard_steps: {}, submitted_at: nil, confirm_readonly: nil)
    end

    def in_progress?
      submitted_at.blank?
    end

    def completed?
      submitted_at.present?
    end
    alias_method :submitted?, :completed?

    def required_score
      required_by_cycle = cpd_cycle&.required_score
      required_by_user = user.cpd_statement_required_score(self) if user.respond_to?(:cpd_statement_required_score)

      [required_by_cycle.to_i, required_by_user.to_i].max
    end

    def carry_forward
      cpd_statement_activities.sum { |activity| activity.carry_forward.to_i }
    end

    # {category_id => 20, category_id => 15}
    def score_per_category
      @score_per_category ||= Hash.new(0).tap do |scores|
        cpd_statement_activities.each { |activity| scores[activity.cpd_category_id] += activity.score.to_i }
      end
    end

  end
end
