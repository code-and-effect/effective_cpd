module Effective
  class CpdAuditResponse < ActiveRecord::Base
    belongs_to :cpd_audit
    belongs_to :cpd_audit_level_section
    belongs_to :cpd_audit_level_question

    has_many :cpd_audit_response_options, dependent: :delete_all
    has_many :cpd_audit_level_question_options, through: :cpd_audit_response_options

    has_one_attached :upload_file

    if respond_to?(:log_changes)
      log_changes(to: :cpd_audit)
    end

    effective_resource do
      # The response
      date            :date
      email           :string
      number          :integer
      long_answer     :text
      short_answer    :text

      timestamps
    end

    scope :submitted, -> { where(cpd_audit: Effective::CpdAudit.where.not(submitted_at: nil)) }
    scope :deep, -> { includes(:cpd_audit, :cpd_audit_level_question) }

    before_validation(if: -> { cpd_audit_level_question.present? }) do
      self.cpd_audit_level_section = cpd_audit_level_question.cpd_audit_level_section
    end

    validates :date, presence: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.date? }
    validates :email, presence: true, email: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.email? }
    validates :number, presence: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.number? }
    validates :long_answer, presence: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.long_answer? }
    validates :short_answer, presence: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.short_answer? }
    validates :upload_file, presence: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.upload_file? }
    validates :cpd_audit_level_question_option_ids, presence: true, if: -> { cpd_audit_level_question&.required? && cpd_audit_level_question.question_option? }

    validates :cpd_audit_level_question_option_ids, if: -> { cpd_audit_level_question&.choose_one? },
      length: { maximum: 1, message: 'please choose 1 option only' }

    validates :cpd_audit_level_question_option_ids, if: -> { cpd_audit_level_question&.select_up_to_1? },
      length: { maximum: 1, message: 'please select 1 option or fewer' }

    validates :cpd_audit_level_question_option_ids, if: -> { cpd_audit_level_question&.select_up_to_2? },
      length: { maximum: 2, message: 'please select 2 options or fewer' }

    validates :cpd_audit_level_question_option_ids, if: -> { cpd_audit_level_question&.select_up_to_3? },
      length: { maximum: 3, message: 'please select 3 options or fewer' }

    validates :cpd_audit_level_question_option_ids, if: -> { cpd_audit_level_question&.select_up_to_4? },
      length: { maximum: 4, message: 'please select 4 options or fewer' }

    validates :cpd_audit_level_question_option_ids, if: -> { cpd_audit_level_question&.select_up_to_5? },
      length: { maximum: 5, message: 'please select 5 options or fewer' }

    def to_s
      'audit response'
    end

    def response
      return nil unless cpd_audit_level_question.present?

      return date if cpd_audit_level_question.date?
      return email if cpd_audit_level_question.email?
      return number if cpd_audit_level_question.number?
      return long_answer if cpd_audit_level_question.long_answer?
      return short_answer if cpd_audit_level_question.short_answer?
      return upload_file if cpd_audit_level_question.upload_file?

      return cpd_audit_level_question_options.first if cpd_audit_level_question.choose_one?
      return cpd_audit_level_question_options.first if cpd_audit_level_question.select_up_to_1?
      return cpd_audit_level_question_options if cpd_audit_level_question.question_option?

      raise('unknown response for unexpected cpd audit question category')
    end

    def category_partial
      cpd_audit_level_question&.category_partial
    end

  end
end
