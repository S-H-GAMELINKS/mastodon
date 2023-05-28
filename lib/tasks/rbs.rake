# frozen_string_literal: true

if Rails.env.development?
  require 'rbs_rails/rake_task'

  RbsRails::RakeTask.new
end
