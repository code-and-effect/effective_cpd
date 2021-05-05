# Effective CPD

Continuing professional development.

An admin creates a set of categories, activites and rules.  User enters number of hours or work done to have a scored statement. Audits.

Works with action_text for content bodies, and active_storage for file uploads.

## Getting Started

This requires Rails 6+ and Twitter Bootstrap 4 and just works with Devise.

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install the [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'haml-rails' # or try using gem 'hamlit-rails'
gem 'effective_cpd'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_cpd:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table names, manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```

Please add the following to your User model:

```
has_many :cpd_statements, -> { Effective::CpdStatement.sorted }, class_name: 'Effective::CpdStatement'
```

Use the following datatables to display to your user their statements and audits and audit reviews:

```haml
%h2 Continuing Professional Development

- # Auditee datatables (4)
- auditing = EffectiveCpdAvailableAuditsDatatable.new(self)
- if auditing.present?
  .mt-4
    %p You have been selected for audit:
    = render_datatable(auditing, simple: true)

- audited = EffectiveCpdCompletedAuditsDatatable.new(self)
- if audited.present?
  .mt-4
    %p You have completed these past audits:
    = render_datatable(audited, simple: true)

- available = EffectiveCpdAvailableCyclesDatatable.new(self)
- if available.present?
  .mt-4
    %p Please submit a CPD statement for the following available #{cpd_cycles_label}:
    = render_datatable(available, simple: true)

- completed = EffectiveCpdCompletedStatementsDatatable.new(self)
- if completed.present?
  .mt-4
    %p You have completed these past statements:
    = render_datatable(completed, simple: true)

- # Auditor / Audit reviewer datatables (2)
- reviewing = EffectiveCpdAvailableAuditReviewsDatatable.new(self)
- if reviewing.present?
  .mt-4
    %p You have been selected to review the following audits:
    = render_datatable(reviewing, simple: true)

- reviewed = EffectiveCpdCompletedAuditReviewsDatatable.new(self)
- if reviewed.present?
  .mt-4
    %p You have completed these past audit reviews:
    = render_datatable(reviewed, simple: true)
```

On the Admin::Users#edit, you can use the following datatables as well:

```haml
%h2 CPD Statements
- datatable = Admin::EffectiveCpdStatementsDatatable.new(user_id: user.id, user_type: user.class.name)
= render_datatable(datatable, inline: true)

%h2 CPD Audits
- datatable = Admin::EffectiveCpdAuditsDatatable.new(user_id: user.id, user_type: user.class.name)
= render_datatable(datatable)

```

Add a link to the admin menu:

```haml
- if can? :admin, :effective_cpd
  - if can? :index, Effective::CpdCategory
    = nav_link_to 'CPD Categories', effective_cpd.admin_cpd_categories_path

  - if can? :index, Effective::CpdCycle
    = nav_link_to 'CPD Cycles', effective_cpd.admin_cpd_cycles_path

  - if can? :index, Effective::CpdAuditLevel
    = nav_link_to 'CPD Audit Levels', effective_cpd.admin_cpd_audit_levels_path

  = nav_divider

  - if can? :index, Effective::CpdStatement
    = nav_link_to 'CPD Statements', effective_cpd.admin_cpd_statements_path

  - if can? :index, Effective::CpdAudit
    = nav_link_to 'CPD Audits', effective_cpd.admin_cpd_audits_path
```

## Configuration

As an admin, visit the CPD Categories, then CPD Cycles, and CPD Audit levels.

Once all these 3 areas have been configured, users can submit statements and audits can be performed.

## Required Score

You can specify the required score in the CPD Cycle.

You can also programatically do it. Add the following to your user class.

```
# This is an ActiveRecord concern to add the has_many :cpd_statements
effective_cpd_user

# We require 100 points in the last 3 years.
def cpd_statement_required_score(cpd_statement)
  # We always consider the 3 year window, of the passed cpd_statement and the last two statements
  last_two_statements = cpd_statements.select do |statement|
    statement.completed? && statement.cpd_cycle_id < cpd_statement.cpd_cycle_id
  end.last(2)

  # They can submit 0 0 100
  return 0 if last_two_statements.length < 2

  # 100 points in the last 3 years.
  required_score = 100

  # Score so far
  existing_score = last_two_statements.sum { |statement| statement.score }
  raise('expected existing_score to be >= 0') if existing_score < 0

  # Required score minus previous
  return 0 if existing_score >= required_score
  (required_score - existing_score)
end
```

## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

## Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
# Regular signed up user. Guest users not supported.
if user.persisted?
  can :new, Effective::CpdStatement
  can [:index, :show, :update], Effective::CpdStatement, user_id: user.id
  can [:index, :show], Effective::CpdCycle
  can([:create, :update, :destroy], Effective::CpdStatementActivity) { |sa| sa.cpd_statement.user_id == user.id }
  can [:index, :show, :update], Effective::CpdAudit, user_id: user.id
end

if user.reviewer?
  can [:index], Effective::CpdAudit
  can [:index, :show, :update], Effective::CpdAuditReview, user_id: user.id
end

if user.admin?
  can :admin, :effective_cpd
  can :manage, Effective::CpdActivity
  can :manage, Effective::CpdCategory
  can :manage, Effective::CpdCycle
  can :manage, Effective::CpdRule

  can :manage, Effective::CpdAuditLevel
  can :manage, Effective::CpdAuditLevelSection
  can :manage, Effective::CpdAuditLevelQuestion

  can :manage, Effective::CpdStatement
  can :manage, Effective::CpdAudit
  can :manage, Effective::CpdAuditReview
end
```

## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
rails test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
