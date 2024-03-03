require_relative '../configuration/env'
require_relative '../util/file'
require_relative 'discord'
require_relative 'pushover'
require_relative 'mailgun'
require 'logger'

module Notifications
  class Hooks
    def initialize
      @file = Util::File.new
      @logger = Logger.new(@file.app('log_path'))
      @env = Env::Env.new.options
    end

    def pg_success
      send(:backup)
    end

    def pg_failure
      send(:error)
    end

    def pg_restore
      send(:restore)
    end

    def s3_success
      send(:s3_success)
    end

    def s3_failure
      send(:s3_failure)
    end

    private

    def send(event)
      @env[:pushover].is_a?(Hash) ? PushOver.new.send(event) : @logger.info('Pushover not configured')
      @env[:discord].is_a?(Hash) ? Discord.new.send(event) : @logger.info('Discord not configured')
      @env[:mailgun].is_a?(Hash) ? MailGun.new.send(event) : @logger.info('Mailgun not configured')
    end
  end
end
