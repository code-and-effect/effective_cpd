class CreateEffectiveCpd < ActiveRecord::Migration[6.0]
  def change
    create_table :cpd_cycles do |t|
      t.string :title

      t.datetime :start_at
      t.datetime :end_at

      t.integer :required_score

      t.string :token
      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_categories do |t|
      t.references :cpd_cycle

      t.string :title
      t.integer :max_credits_per_cycle
      t.integer :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :cpd_activities do |t|
      t.references :cpd_cycle
      t.references :cpd_category

      t.string :title
      t.integer :position

      t.string :formula

      t.string :amount_label
      t.string :amount2_label

      t.integer :max_credits_per_cycle
      t.integer :max_cycles_can_carry_forward

      t.boolean :requires_upload_file, default: false

      t.datetime :updated_at
      t.datetime :created_at
    end

  end
end
