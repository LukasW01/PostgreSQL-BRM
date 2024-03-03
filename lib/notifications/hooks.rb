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
      @env = Env::Env.new
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

    private

    def send(event)
      pushover? ? PushOver.new.send(event) : @logger.info('Pushover not configured')
      discord? ? Discord.new.send(event) : @logger.info('Discord not configured')
      mailgun? ? MailGun.new.send(event) : @logger.info('Mailgun not configured')
    end

    def mailgun?
      @env.get_key(:mailgun).is_a?(Hash)
    end

    def pushover?
      @env.get_key(:pushover).is_a?(Hash)
    end

    def discord?
      @env.get_key(:discord).is_a?(Hash)
    end
  end
end
