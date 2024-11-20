require_relative '../configuration/env'
require_relative '../util/file'
require_relative 'notification'
require 'pushover'
require 'logger'

module Notifications
  class PushOver
    attr_reader :pushover

    def initialize
      @file = Util::File.new
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.get_key(:pushover)
      @notification = Notification.new
    end

    def send(event)
      event_file = @file.event(event)

      @logger.info("Sending message to Pushover for event: #{event}")
      begin
        Pushover::Message.new(
          token: @env['app_token'], user: @env['user_key'],
          title: "pg_brm - #{event_file['status']}",
          message: "#{event_file['description']} \n\n#{event_file['info'].gsub('%s', @notification.databases)} \n\n#{event_file['schedule']&.gsub('%s', @notification.cronex)}",
          priority: @notification.priority(event), expire: 3600, retry: 60
        ).push
      rescue StandardError => e
        @logger.error("Error sending message to Pushover \nERROR: #{e.message}")
        exit!
      end
    end
  end
end
