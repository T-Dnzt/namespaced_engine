# frozen_string_literal: true

require "test_helper"
require_relative File.expand_path("../../../../lib/generators/modular/engine_generator", __FILE__)

class Modular::EngineGeneratorTest < ::Rails::Generators::TestCase
  include GeneratorTestHelpers

  tests Modular::EngineGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))

  Minitest.after_run do
    remove_generator_sample_app
  end

  setup do
    run_generator(['contacts', '--namespace=blast'])
  end

  test "generates an engine" do
    assert_file "contacts/contacts.gemspec"
  end
end