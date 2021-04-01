module Effective
  class CpdCycle < ActiveRecord::Base
    acts_as_tokened

    has_rich_text :all_steps_content    # Update build_from_cycle() below if these change
    has_rich_text :start_content
    has_rich_text :activities_content
    has_rich_text :submit_content
    has_rich_text :complete_content

    has_many :cpd_categories, -> { order(:position) }, inverse_of: :cpd_cycle, dependent: :destroy
    accepts_nested_attributes_for :cpd_categories, allow_destroy: true

    if respond_to?(:log_changes)
      log_changes
    end

    effective_resource do
      # Acts as tokened
      token                 :string, permitted: false

      title                 :string       # 2021 Continuing Professional Development
      start_at              :datetime
      end_at                :datetime

      required_score        :integer  # If set, a user must fill out this many activities to finish a statement

      timestamps
    end

    scope :deep, -> {
      with_rich_text_all_steps_content
      .with_rich_text_start_content
      .with_rich_text_activities_content
      .with_rich_text_submit_content
      .with_rich_text_complete_content
      .includes(cpd_categories: :cpd_activity)
    }

    scope :sorted, -> { order(:start_at) }

    scope :upcoming, -> { where('start_at > ?', Time.zone.now) }
    scope :available, -> { where('start_at <= ? AND (end_at > ? OR end_at IS NULL)', Time.zone.now, Time.zone.now) }
    scope :completed, -> { where('end_at < ?', Time.zone.now) }

    before_validation(if: -> { new_record? && cpd_categories.blank? }) do
      cycle = CpdCycle.latest_cycle
      build_from_cycle(cycle: cycle) if cycle
    end

    validates :title, presence: true
    validates :start_at, presence: true
    validates :cpd_categories, presence: true

    validate(if: -> { start_at.present? && end_at.present? }) do
      self.errors.add(:end_at, 'must be after the start date') unless end_at > start_at
    end

    def self.latest_cycle
      order(id: :desc).first
    end

    def build_from_cycle(cycle:)
      raise('expected a CpdCycle') unless cycle.kind_of?(CpdCycle)

      # Cycle
      attributes = cycle.dup.attributes.except('title', 'token', 'start_at', 'end_at')
      assign_attributes(attributes)

      [:all_steps_content, :start_content, :activities_content, :submit_content, :complete_content].each do |rich_text|
        self.send("#{rich_text}=", cycle.send(rich_text))
      end

      # Categories
      cycle.cpd_categories.each do |category|
        attributes = category.dup.attributes.except('cpd_cycle_id')
        cpd_category = self.cpd_categories.build(attributes)
        cpd_category.body = category.body

        # Category Activities
        category.cpd_activities.each do |activity|
          attributes = activity.dup.attributes.compact.except('cpd_cycle_id', 'cpd_category_id')
          cpd_activity = cpd_category.cpd_activities.build(attributes)
          cpd_activity.body = activity.body
        end
      end

      self
    end

    def to_s
      title.presence || 'New CPD Cycle'
    end

    def available?
      started? && !ended?
    end

    def started?
      start_at_was.present? && Time.zone.now >= start_at_was
    end

    def ended?
      end_at.present? && end_at < Time.zone.now
    end

    def available_date
      if start_at && end_at && start_at.to_date == end_at.to_date
        "#{start_at.strftime('%F at %H:%M')} to #{end_at.strftime('%H:%M')}"
      elsif start_at && end_at
        "#{start_at.strftime('%F at %H:%M')} to #{end_at.strftime('%F %H:%M')}"
      elsif start_at
        "#{start_at.strftime('%F at %H:%M')}"
      end
    end

  end
end
