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

Render the "available statements for current_user" datatable on your user dashboard:

```haml
%h2 Continuing Professional Development

%p Please submit a CPD statement for the following available #{cpd_cycles_label}:
= render_datatable(EffectiveCpdDatatable.new, simple: true)

- datatable = EffectiveCpdStatementsDatatable.new(self)
- if datatable.present?
  .mt-4
    %p You completed these statements:
    = render_datatable(datatable, simple: true)

```

Add a link to the admin menu:

```haml
- if can? :admin, :effective_cpd
  = link_to 'CPD Categories', effective_cpd.admin_cpd_categories_path
  = link_to 'CPD Cycles', effective_cpd.admin_cpd_cycles_path
  = link_to 'CPD Statements', effective_cpd.admin_cpd_statements_path
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
end

if user.admin?
  can :admin, :effective_cpd
  can :manage, Effective::CpdActivity
  can :manage, Effective::CpdCategory
  can :manage, Effective::CpdCycle
  can :manage, Effective::CpdRule
  can :manage, Effective::CpdStatement
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
