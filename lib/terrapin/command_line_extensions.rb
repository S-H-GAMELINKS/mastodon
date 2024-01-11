# frozen_string_literal: false

require 'English'
module Terrapin
  class CommandLine
    def run(interpolations = {})
      Sidekiq.logger.info('###################################################')
      Sidekiq.logger.info('Started Terrapin::CommandLine#run')
      Sidekiq.logger.info('###################################################')

      @exit_status = nil
      begin
        full_command = command(interpolations)
        log("#{colored('Command')} :: #{full_command}")
        @output = execute(full_command)
        log("#{colored('Output')} :: #{@output}")
        @output
      rescue Errno::ENOENT => e
        Sidekiq.logger.info('###################################################')
        Sidekiq.logger.info('raise Terrapin::CommandNotFoundError in Terrapin::CommandLine#run')
        Sidekiq.logger.info('###################################################')
        raise Terrapin::CommandNotFoundError, e.message
      ensure
        @exit_status = $CHILD_STATUS.respond_to?(:exitstatus) ? $CHILD_STATUS.exitstatus : 0
      end

      if @exit_status == 127
        Sidekiq.logger.info('###################################################')
        Sidekiq.logger.info('raise Terrapin::CommandNotFoundError in Terrapin::CommandLine#run')
        Sidekiq.logger.info('###################################################')
        raise Terrapin::CommandNotFoundError
      end

      unless @expected_outcodes.include?(@exit_status)
        message = [
          "Command '#{full_command}' returned #{@exit_status}. Expected #{@expected_outcodes.join(', ')}",
          "Here is the command output: STDOUT:\n", command_output,
          "\nSTDERR:\n", command_error_output
        ].join("\n")

        Sidekiq.logger.info('###################################################')
        Sidekiq.logger.info('raise Terrapin::ExitStatusError in Terrapin::CommandLine#run')
        Sidekiq.logger.info(message)
        Sidekiq.logger.info('###################################################')

        raise Terrapin::ExitStatusError, message
      end

      Sidekiq.logger.info('###################################################')
      Sidekiq.logger.info('Finished Terrapin::CommandLine#run')
      Sidekiq.logger.info('###################################################')

      command_output
    end
  end
end
