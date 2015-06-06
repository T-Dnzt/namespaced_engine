require 'rails/generators'
require 'active_support/core_ext/hash/slice'
require "rails/generators/rails/app/app_generator"
require 'date'

module Modular

  class EngineBuilder
    def rakefile
      template "Rakefile"
    end

    def app
      directory 'app'
      empty_directory_with_keep_file "app/assets/images/#{namespaced_name}"
      empty_directory "app/decorators"
      empty_directory_with_keep_file "app/decorators/controllers"
      empty_directory_with_keep_file "app/decorators/models"
      empty_directory_with_keep_file "app/overrides"
      empty_directory_with_keep_file "app/views/#{namespaced_name}/overrides"

    end

    def readme
      template "README.rdoc"
    end

    def gemfile
      template "Gemfile"
    end

    def license
      template "MIT-LICENSE"
    end

    def gemspec
      template "%engine_loader%.gemspec"
    end

    def gitignore
      template "gitignore", ".gitignore"
    end

    def lib
      template "lib/%namespaced_name%.rb"
      template "lib/%engine_loader%.rb"
      template "lib/tasks/%namespaced_name%_tasks.rake"
      template "lib/%namespaced_name%/version.rb"
      template "lib/%namespaced_name%/engine.rb"
    end

    def config
      template "config/routes.rb" if engine?
    end

    def test
      template "test/test_helper.rb"
      template "test/%namespaced_name%_test.rb"
      append_file "Rakefile", <<-EOF.gsub(/^\s+\|/, '')
        |  #{rakefile_test_tasks}
        |
        |  task default: :test
      EOF
      if engine?
        template "test/integration/navigation_test.rb"
      end
    end

    PASSTHROUGH_OPTIONS = [
      :skip_active_record, :skip_action_mailer, :skip_javascript, :database,
      :javascript, :quiet, :pretend, :force, :skip
    ]

    def stylesheets
      copy_file "rails/stylesheets.css",
                  "app/assets/stylesheets/#{namespaced_name}/application.css"
    end

    def javascripts
      return if options.skip_javascript?

      template "rails/javascripts.js",
                 "app/assets/javascripts/#{namespaced_name}/application.js"
    end

    def bin(force = false)
      return unless engine?

      directory "bin", force: force do |content|
        "#{shebang}\n" + content
      end
      chmod "bin", 0755, verbose: false
    end

    def gemfile_entry
      return unless inside_application?

      gemfile_in_app_path = File.join(rails_app_path, "Gemfile")
      if File.exist? gemfile_in_app_path
        entry = "gem '#{name}', path: '#{relative_path}'"
        append_file gemfile_in_app_path, entry
      end
    end
  end

  class EngineGenerator < ::Rails::Generators::AppBase # :nodoc:
    source_root File.expand_path("../templates", __FILE__)
    add_shared_options_for "engine"

    remove_argument :app_path
    argument :engine_path, type: :string

    alias_method :app_path, :engine_path

    class_option :namespace,    type: :string, default: '',
                                desc: 'Add one or more namespace to your modular engine. Ex: namespace1::namespace2'

    def initialize(*args)
      super

      unless engine_path
        raise Error, 'Engine name should be provided in arguments. For details run: rails g modular:engine --help'
      end
    end

    public_task :set_default_accessors!
    public_task :create_root

    def create_root_files
      build(:readme)
      build(:rakefile)
      build(:gemspec)   unless options[:skip_gemspec]
      build(:license)
      build(:gitignore) unless options[:skip_git]
      build(:gemfile)   unless options[:skip_gemfile]
    end

    def create_app_files
      build(:app)
    end

    def create_config_files
      build(:config)
    end

    def create_lib_files
      build(:lib)
    end

    def create_public_stylesheets_files
      build(:stylesheets)
    end

    def create_javascript_files
      build(:javascripts)
    end

    def create_images_directory
      build(:images)
    end

    def create_bin_files
      build(:bin)
    end

    def create_test_files
      build(:test) unless options[:skip_test]
    end

    def update_gemfile
      build(:gemfile_entry) unless options[:skip_gemfile_entry]
    end

    def finish_template
      build(:leftovers)
    end

    public_task :apply_rails_template, :run_bundle

    def name
      @name ||= begin
        # same as ActiveSupport::Inflector#underscore except not replacing '-'
        underscored = original_name.dup
        underscored.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        underscored.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        underscored.downcase!

        underscored
      end
    end

    def underscored_name
      @underscored_name ||= original_name.underscore
    end

    def namespaced_name
      @namespaced_name ||= modules.join('/').underscore#name.gsub('-', '/')
    end

  protected

    def app_templates_dir
      "../app/templates"
    end

    def engine?
      true
    end

    def skip_git?
      options[:skip_git]
    end

    def self.banner
      "rails generate modular:engine #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    def original_name
      @original_name ||= File.basename(destination_root)
    end

    def modules
      @modules ||= options[:namespace].camelize.split('::').push(original_name.camelize)
    end

    def engine_loader
      @engine_loader ||= modules.join('_').underscore
    end

    def wrap_in_modules(content)
      content = "#{content}".strip.gsub(/\W$\n/, '')
      modules.reverse.inject(content) do |content, mod|
        str = "module #{mod}\n"
        str += content.lines.map { |line| "  #{line}" }.join
        str += content.present? ? "\nend" : "end"
      end
    end

    def wrap_in_modules_with_new_lines(content)
      modules.reverse.inject(content) do |content, mod|
        str = "module #{mod}\n"
        str += content.lines.map { |line| "  #{line}" }.join
        str += content.present? ? "\nend" : "end"
      end
    end

    def camelized_modules
      @camelized_modules ||= namespaced_name.camelize
    end

    def humanized
      @humanized ||= original_name.underscore.humanize
    end

    def camelized
      @camelized ||= name.gsub(/\W/, '_').squeeze('_').camelize
    end

    def author
      default = "TODO: Write your name"
      if skip_git?
        @author = default
      else
        @author = `git config user.name`.chomp rescue default
      end
    end

    def email
      default = "TODO: Write your email address"
      if skip_git?
        @email = default
      else
        @email = `git config user.email`.chomp rescue default
      end
    end

    def valid_const?
      if original_name =~ /-\d/
        raise Rails::Generators::Error, "Invalid engine name #{original_name}. Please give a name which does not contain a namespace starting with numeric characters."
      elsif original_name =~ /[^\w-]+/
        raise Rails::Generators::Error, "Invalid engine name #{original_name}. Please give a name which uses only alphabetic, numeric, \"_\" or \"-\" characters."
      elsif camelized =~ /^\d/
        raise Rails::Generators::Error, "Invalid engine name #{original_name}. Please give a name which does not start with numbers."
      elsif Rails::Generators::RESERVED_NAMES.include?(name)
        raise Rails::Generators::Error, "Invalid engine name #{original_name}. Please give a name which does not match one of the reserved rails words."
      elsif Object.const_defined?(modules.first)
        warn "[WARNING]: Constant #{modules.first} is already defined. Please choose another namespace."
      end
    end

    def get_builder_class
      EngineBuilder
    end

    def mute(&block)
      shell.mute(&block)
    end

    def rails_app_path
      APP_PATH.sub("/config/application", "") if defined?(APP_PATH)
    end

    def inside_application?
      rails_app_path && app_path =~ /^#{rails_app_path}/
    end

    def relative_path
      return unless inside_application?
      app_path.sub(/^#{rails_app_path}\//, '')
    end

    def rakefile_test_tasks
      ''
    end
  end

end
