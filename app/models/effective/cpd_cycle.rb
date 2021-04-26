module Effective
  class CpdCycle < ActiveRecord::Base
    has_rich_text :all_steps_content    # Update build_from_cycle() below if these change
    has_rich_text :start_content
    has_rich_text :activities_content
    has_rich_text :agreements_content
    has_rich_text :submit_content
    has_rich_text :complete_content

    has_many :cpd_rules, dependent: :delete_all
    accepts_nested_attributes_for :cpd_rules, allow_destroy: true

    has_many :cpd_statements

    if respond_to?(:log_changes)
      log_changes(except: [:cpd_statements])
    end

    effective_resource do
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
      .includes(:cpd_rules)
    }

    scope :sorted, -> { order(:id) }

    scope :upcoming, -> { where('start_at > ?', Time.zone.now) }
    scope :available, -> { where('start_at <= ? AND (end_at > ? OR end_at IS NULL)', Time.zone.now, Time.zone.now) }
    scope :completed, -> { where('end_at < ?', Time.zone.now) }

    before_validation(if: -> { new_record? && cpd_rules.blank? }) do
      cycle = CpdCycle.latest_cycle
      build_from_cycle(cycle: cycle) if cycle
    end

    validates :title, presence: true
    validates :start_at, presence: true
    validates :required_score, numericality: { greater_than: 0, allow_nil: true }

    validate(if: -> { start_at.present? && end_at.present? }) do
      self.errors.add(:end_at, 'must be after the start date') unless end_at > start_at
    end

    def self.latest_cycle
      order(id: :desc).first
    end

    def to_s
      title.presence || 'New CPD Cycle'
    end

    def build_from_cycle(cycle:)
      raise('expected a CpdCycle') unless cycle.kind_of?(CpdCycle)

      # Cycle
      attributes = cycle.dup.attributes.except('title', 'token', 'start_at', 'end_at')
      assign_attributes(attributes)

      [:all_steps_content, :start_content, :activities_content, :submit_content, :complete_content].each do |rich_text|
        self.send("#{rich_text}=", cycle.send(rich_text))
      end

      cycle.cpd_rules.each do |rule|
        attributes = rule.dup.attributes.except('cpd_cycle_id')
        self.cpd_rules.build(attributes)
      end

      self
    end

    # Find or build
    def rule_for(ruleable)
      raise('expected a CpdCategory or CpdActivity') unless ruleable.kind_of?(CpdActivity) || ruleable.kind_of?(CpdCategory)

      rule = cpd_rules.find { |rule| rule.ruleable_id == ruleable.id && rule.ruleable_type == ruleable.class.name }
      rule ||= cpd_rules.build(ruleable: ruleable)
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
      if start_at && end_at
        "#{start_at.strftime('%F')} to #{end_at.strftime('%F')}"
      elsif start_at
        "#{start_at.strftime('%F')}"
      end
    end

  end
end
