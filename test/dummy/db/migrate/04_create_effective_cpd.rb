class CreateEffectiveCpd < ActiveRecord::Migration[6.0]
  def change
    create_table :cpd_cycles do |t|
      t.string :title

      t.datetime :start_at
      t.datetime :end_at

      t.integer :required_score

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_categories do |t|
      t.string :title
      t.integer :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_activities do |t|
      t.references :cpd_category

      t.string :title
      t.integer :position

      t.string :amount_label
      t.string :amount2_label

      t.boolean :requires_upload_file, default: false

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_rules do |t|
      t.references :cpd_cycle
      t.integer :ruleable_id
      t.string :ruleable_type

      t.text :credit_description
      t.string :formula

      t.integer :max_credits_per_cycle
      t.integer :max_cycles_can_carry_forward
      t.boolean :unavailable, default: false

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_statement_activities do |t|
      t.references :cpd_statement
      t.references :cpd_activity
      t.references :cpd_category
      t.references :original

      t.integer :amount
      t.integer :amount2

      t.text :description

      t.integer :carry_over
      t.integer :score
      t.integer :carry_forward

      t.text :reduced_messages

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_statements do |t|
      t.references :cpd_cycle

      t.integer :user_id
      t.string :user_type

      t.string :token

      t.integer :score

      t.boolean :confirm_read
      t.boolean :confirm_factual
      t.boolean :confirm_readonly

      t.datetime :submitted_at

      t.text :wizard_steps

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_levels do |t|
      t.string :title
      t.text   :determinations

      t.boolean :conflict_of_interest
      t.boolean :can_request_exemption
      t.boolean :can_request_extension

      t.integer :days_to_submit
      t.integer :days_to_review
      t.integer :days_to_declare_conflict
      t.integer :days_to_request_exemption
      t.integer :days_to_request_extension

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_level_sections do |t|
      t.references :cpd_audit_level

      t.string :title
      t.integer :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_level_questions do |t|
      t.references :cpd_audit_level
      t.references :cpd_audit_level_section

      t.text      :title
      t.string    :category
      t.boolean   :required, default: true

      t.integer   :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_level_question_options do |t|
      t.references :cpd_audit_level_question, index: false

      t.text      :title
      t.integer   :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audits do |t|
      t.references :cpd_audit_level

      t.integer :user_id
      t.string :user_type

      t.date :notification_date
      t.date :extension_date

      t.string :determination

      t.boolean :conflict_of_interest
      t.text :conflict_of_interest_reason

      t.boolean :exemption_request
      t.text :exemption_request_reason

      t.boolean :extension_request
      t.text :extension_request_reason
      t.date :extension_request_date

      t.string :status
      t.text :status_steps

      t.datetime :started_at
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.datetime :closed_at

      t.string :token

      t.text :wizard_steps

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_reviews do |t|
      t.references :cpd_audit_level
      t.references :cpd_audit

      t.integer :user_id
      t.string  :user_type

      t.text    :comments
      t.string  :recommendation

      t.boolean :conflict_of_interest
      t.text :conflict_of_interest_reason

      t.datetime :submitted_at

      t.string :token

      t.text :wizard_steps

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_review_items do |t|
      t.references :cpd_audit_review

      t.integer :item_id
      t.string :item_type

      t.string :recommendation
      t.text :comments

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_level_responses do |t|
      t.references :cpd_audit
      t.references :cpd_audit_level_question

      t.date :date
      t.string :email
      t.integer :number
      t.text :long_answer
      t.text :short_answer

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_audit_level_response_options do |t|
      t.references :cpd_audit_response
      t.references :cpd_audit_level_question_option, index: false

      t.datetime :updated_at
      t.datetime :created_at
    end

  end
end
