# frozen_string_literal: false

module Paperclip
  module Helpers
    def run(cmd, arguments = '', interpolation_values = {}, local_options = {})
      Sidekiq.logger.info('###################################################')
      Sidekiq.logger.info('Started Paperclip.run')
      Sidekiq.logger.info('###################################################')

      command_path = options[:command_path]
      terrapin_path_array = Terrapin::CommandLine.path.try(:split, Terrapin::OS.path_separator)

      Terrapin::CommandLine.path = [terrapin_path_array, command_path].flatten.compact.uniq

      local_options = local_options.merge(logger: logger) if logging? && (options[:log_command] || local_options[:log_command])

      result = Terrapin::CommandLine.new(cmd, arguments, local_options).run(interpolation_values)

      Sidekiq.logger.info('###################################################')
      Sidekiq.logger.info('Finished Paperclip.run')
      Sidekiq.logger.info('###################################################')

      result
    end
  end
end
