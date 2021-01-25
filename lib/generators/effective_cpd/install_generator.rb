module EffectiveCpd
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc 'Creates an EffectiveCpd initializer in your application.'

      source_root File.expand_path('../../templates', __FILE__)

      def self.next_migration_number(dirname)
        if not ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          '%.3d' % (current_migration_number(dirname) + 1)
        end
      end

      def copy_initializer
        template ('../' * 3) + 'config/effective_cpd.rb', 'config/initializers/effective_cpd.rb'
      end

      def create_migration_file
        #@polls_table_name = ':' + EffectivePolls.polls_table_name.to_s
        migration_template ('../' * 3) + 'db/migrate/01_create_effective_cpd.rb.erb', 'db/migrate/create_effective_cpd.rb'
      end

      def copy_mailer_preview
        mailer_preview_path = (Rails.application.config.action_mailer.preview_path rescue nil)

        if mailer_preview_path.present?
          template 'effective_cpd_mailer_preview.rb', File.join(mailer_preview_path, 'effective_cpd_mailer_preview.rb')
        else
          puts "couldn't find action_mailer.preview_path. Skipping effective_cpd_mailer_preview."
        end
      end

    end
  end
end
