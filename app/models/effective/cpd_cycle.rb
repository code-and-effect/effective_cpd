module Effective
  class CpdCycle < ActiveRecord::Base
    has_rich_text :all_steps_content
    has_rich_text :start_content
    has_rich_text :activities_content
    has_rich_text :submit_content
    has_rich_text :complete_content

    acts_as_tokened

    if respond_to?(:log_changes)
      log_changes()
    end

    effective_resource do
      # Acts as tokened
      token                  :string, permitted: false

      title                 :string       # 2021 Continuing Professional Development
      start_at              :datetime
      end_at                :datetime

      required_score        :integer  # If set, a user must fill out this many activities to finish a statement

      timestamps
    end

    scope :deep, -> {
      .all_steps_content
      .with_rich_text_start_content
      .with_rich_text_activities_content
      .with_rich_text_submit_content
      .with_rich_text_complete_content
    }

    scope :sorted, -> { order(:start_at) }

    scope :upcoming, -> { where('start_at > ?', Time.zone.now) }
    scope :available, -> { where('start_at <= ? AND (end_at > ? OR end_at IS NULL)', Time.zone.now, Time.zone.now) }
    scope :completed, -> { where('end_at < ?', Time.zone.now) }

    validates :title, presence: true
    validates :start_at, presence: true

    validate(if: -> { start_at.present? && end_at.present? }) do
      self.errors.add(:end_at, 'must be after the start date') unless end_at > start_at
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
