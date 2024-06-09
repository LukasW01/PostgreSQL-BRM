require_relative '../configuration/env'
require_relative 'discord'
require_relative 'pushover'
require_relative 'mailgun'
require 'logger'

module Notifications
  class Hooks
    def initialize
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.options
    end

    def send(event)
      @env[:pushover].is_a?(Hash) ? PushOver.new.send(event) : @logger.info('Pushover not configured')
      @env[:discord].is_a?(Hash) ? Discord.new.send(event) : @logger.info('Discord not configured')
      @env[:mailgun].is_a?(Hash) ? MailGun.new.send(event) : @logger.info('Mailgun not configured')
    end
  end
end
