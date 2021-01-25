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
%h2 Continuing Professional Development STatements
%p You may submit a statement for the following years.
= render_datatable(EffectiveCpdStatementsDatatable.new, simple: true)
```

Add a link to the admin menu:

```haml
- if can? :admin, :effective_cpd
  = link_to 'CPD', effective_cpd.admin_cpd_years_path
```

Set up your permissions:

```ruby
# Regular signed up user. Guest users not supported.
if user.persisted?
end

if user.admin?
  can :admin, :effective_cpd
end
```

## Usage

%ODO


## Authorization

All authorization checks are handled via the config.authorization_method found in the `app/config/initializers/effective_cpd.rb` file.

It is intended for flow through to CanCan or Pundit, but neither of those gems are required.

This method is called by all controller actions with the appropriate action and resource

Action will be one of [:index, :show, :new, :create, :edit, :update, :destroy]

Resource will the appropriate Effective::CpdStatement object or class

The authorization method is defined in the initializer file:

```ruby
# As a Proc (with CanCan)
config.authorization_method = Proc.new { |controller, action, resource| authorize!(action, resource) }
```

```ruby
# As a Custom Method
config.authorization_method = :my_authorization_method
```

and then in your application_controller.rb:

```ruby
def my_authorization_method(action, resource)
  current_user.is?(:admin) || EffectivePunditPolicy.new(current_user, resource).send('#{action}?')
end
```

or disabled entirely:

```ruby
config.authorization_method = false
```

If the method or proc returns false (user is not authorized) an Effective::AccessDenied exception will be raised

You can rescue from this exception by adding the following to your application_controller.rb:

```ruby
rescue_from Effective::AccessDenied do |exception|
  respond_to do |format|
    format.html { render 'static_pages/access_denied', status: 403 }
    format.any { render text: 'Access Denied', status: 403 }
  end
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
