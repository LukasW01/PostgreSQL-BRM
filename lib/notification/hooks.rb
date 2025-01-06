require_relative '../configuration/env'
require_relative 'discord'
require_relative 'pushover'
require_relative 'mailgun'
require 'logger'

module Notifications
  class Hooks
    def initialize
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new
    end

    def send(event)
      @env.options[:pushover].is_a?(Hash) ? PushOver.new.send(event) : @logger.info('Pushover not configured')
      @env.options[:discord].is_a?(Hash) ? Discord.new.send(event) : @logger.info('Discord not configured')
      @env.options[:mailgun].is_a?(Hash) ? MailGun.new.send(event) : @logger.info('Mailgun not configured')
    end
  end
end
