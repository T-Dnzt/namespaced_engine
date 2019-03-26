# frozen_string_literal: true

require 'test_helper'
require_relative File.expand_path('../../../lib/generators/modular/engine_generator', __dir__)

class Modular::EngineGeneratorTest < ::Rails::Generators::TestCase
  include Minitest::Hooks

  tests Modular::EngineGenerator
  destination File.expand_path('../tmp', File.dirname(__FILE__))

  before(:all) do
    run_generator(['contacts', '--namespace=blast'])
  end

  after(:all) do
    FileUtils.rm_rf(destination_root)
  end

  test 'generates a gemspec file' do
    assert_file 'contacts/contacts.gemspec'
  end

  test 'generates controllers/blast/application_controller.rb' do
    assert_file 'contacts/app/controllers/blast/contacts/application_controller.rb'
  end

  test 'generates helpers/blast/application_helper.rb' do
    assert_file 'contacts/app/helpers/blast/contacts/application_helper.rb'
  end
end
