module Effective
  class CpdStatementActivity < ActiveRecord::Base
    belongs_to :cpd_statement
    belongs_to :cpd_category
    belongs_to :cpd_activity

    belongs_to :original, class_name: 'CpdStatementActivity', optional: true # If this is a Carryover, the original_statement_activity will be set.
    #has_many :carried, class_name: 'CpdStatementActivity', foreign_key: 'original_id', dependent: :delete_all

    has_many_attached :files

    if respond_to?(:log_changes)
      log_changes(to: :cpd_statement)
    end

    effective_resource do
      amount            :integer
      amount2           :integer

      description       :text

      carry_over        :integer    # carry_over_from_last_cycle
      score             :integer
      carry_forward     :integer    # carry_forward_to_next_cycle

      reduced_messages  :text

      timestamps
    end

    serialize :reduced_messages, Hash

    scope :deep, -> { includes(:cpd_statement, :cpd_category, :cpd_activity, :original) }
    scope :sorted, -> { order(:id) }

    validates :original, presence: true, if: -> { carry_over.to_i > 0 }

    def to_s
      'activity'
    end

    def reduced_messages
      self[:reduced_messages] ||= {}
    end

    def is_carry_over?
      original.present?
    end

    def original_cycle
      (original || self).cpd_statement.cpd_cycle
    end

    # Will display as read-only on form
    def locked?
      is_carry_over? || cpd_statement&.completed?
    end

    def to_debug
      "id=#{id}, score=#{score}, carry_foward=#{carry_forward}, carry_from_last=#{carry_over}, original=#{original&.id}"
    end

  end
end
