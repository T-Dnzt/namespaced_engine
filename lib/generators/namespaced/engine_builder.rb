# frozen_string_literal: true

module Namespaced
  class EngineBuilder
    def rakefile
      template 'Rakefile'
    end

    def app
      empty_directory_with_keep_file 'app/models'
      empty_directory_with_keep_file "app/controllers/#{namespaced_name}"
      empty_directory_with_keep_file 'app/mailers'
      empty_directory 'app/decorators'
      empty_directory_with_keep_file 'app/decorators/controllers'
      empty_directory_with_keep_file 'app/decorators/models'
      empty_directory_with_keep_file 'app/overrides'
      empty_directory_with_keep_file "app/views/#{namespaced_name}/overrides"

      template 'app/controllers/%namespaced_name%/application_controller.rb'
      template 'app/helpers/%namespaced_name%/application_helper.rb'
      template 'app/jobs/%namespaced_name%/application_job.rb'
      template 'app/jobs/%namespaced_name%/application_job.rb'
      template 'app/mailers/%namespaced_name%/application_mailer.rb'
      template 'app/models/%namespaced_name%/application_record.rb'
      template 'app/views/layouts/%namespaced_name%/application.html.erb'

      unless api?
        empty_directory_with_keep_file "app/assets/images/#{namespaced_name}"
        empty_directory_with_keep_file 'app/helpers'
        empty_directory_with_keep_file 'app/views'
      end
    end

    def readme
      template 'README.md'
    end

    def gemfile
      template 'Gemfile'
    end

    def license
      template 'MIT-LICENSE'
    end

    def gemspec
      template '%name%.gemspec'
    end

    def gitignore
      template 'gitignore', '.gitignore'
    end

    def lib
      template 'lib/%namespaced_name%.rb'
      template 'lib/tasks/%namespaced_name%_tasks.rake'
      template 'lib/%namespaced_name%/version.rb'

      if engine?
        template 'lib/%namespaced_name%/engine.rb'
      else
        template 'lib/%namespaced_name%/railtie.rb'
      end
    end

    def config
      template 'config/routes.rb' if engine?
    end

    def test
      template 'test/test_helper.rb'
      template 'test/%namespaced_name%_test.rb'
      append_file 'Rakefile', <<-EOF

#{rakefile_test_tasks}
task default: :test
      EOF
      template 'test/integration/navigation_test.rb' if engine?
    end

    PASSTHROUGH_OPTIONS = %i[
      skip_active_record skip_active_storage skip_action_mailer skip_javascript skip_action_cable skip_sprockets database
      javascript skip_yarn api quiet pretend skip
    ].freeze

    def generate_test_dummy(force = false)
      opts = (options.dup || {}).keep_if { |k, _| PASSTHROUGH_OPTIONS.map(&:to_s).include?(k) }
      opts[:force] = force
      opts[:skip_bundle] = true
      opts[:skip_listen] = true
      opts[:skip_git] = true
      opts[:skip_turbolinks] = true
      opts[:dummy_app] = true

      invoke Rails::Generators::AppGenerator,
            [File.expand_path(dummy_path, destination_root)], opts
    end

    def test_dummy_config
      template 'rails/boot.rb', "#{dummy_path}/config/boot.rb", force: true
      template 'rails/application.rb', "#{dummy_path}/config/application.rb", force: true
      if mountable?
        template 'rails/routes.rb', "#{dummy_path}/config/routes.rb", force: true
      end
    end

    def test_dummy_assets
      template 'rails/javascripts.js',    "#{dummy_path}/app/assets/javascripts/application.js", force: true
      template 'rails/stylesheets.css',   "#{dummy_path}/app/assets/stylesheets/application.css", force: true
      template 'rails/dummy_manifest.js', "#{dummy_path}/app/assets/config/manifest.js", force: true
    end

    def test_dummy_clean
      inside dummy_path do
        remove_file 'db/seeds.rb'
        remove_file 'Gemfile'
        remove_file 'lib/tasks'
        remove_file 'public/robots.txt'
        remove_file 'README.md'
        remove_file 'test'
        remove_file 'vendor'
      end
    end

    def assets_manifest
      template 'rails/engine_manifest.js', "app/assets/config/#{underscored_name}_manifest.js"
    end

    def stylesheets
      if mountable?
        copy_file 'rails/stylesheets.css',
                  "app/assets/stylesheets/#{namespaced_name}/application.css"
      elsif full?
        empty_directory_with_keep_file "app/assets/stylesheets/#{namespaced_name}"
      end
    end

    def javascripts
      return if options.skip_javascript?

      if mountable?
        template 'rails/javascripts.js',
                "app/assets/javascripts/#{namespaced_name}/application.js"
      elsif full?
        empty_directory_with_keep_file "app/assets/javascripts/#{namespaced_name}"
      end
    end

    def bin(force = false)
      bin_file = engine? ? 'bin/rails.tt' : 'bin/test.tt'
      template bin_file, force: force do |content|
        "#{shebang}\n" + content
      end
      chmod 'bin', 0o755, verbose: false
    end

    def gemfile_entry
      return unless inside_application?

      gemfile_in_app_path = File.join(rails_app_path, 'Gemfile')
      if File.exist? gemfile_in_app_path
        entry = "\ngem '#{name}', path: '#{relative_path}'"
        append_file gemfile_in_app_path, entry
      end
    end
  end
end