# # frozen_string_literal: true

# require 'spec_helper'

# module Modular
#   describe EngineGenerator do
#     before(:all) do
#       generate_sample_app
#     end

#     after(:all) do
#       remove_sample_app
#     end

#     it 'does something' do
#       system "rails generate modular:engine dummy/ --namespace='my_namespace'"
#     end

#     def generate_sample_app
#       system "rails new dummy --skip-active-record --skip-test-unit --skip-spring --skip-bundle"
#     end

#     def remove_sample_app
#       system "rm -rf dummy/"
#     end
#   end
# end
