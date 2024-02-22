require 'pushover'
require_relative '../util/event'
require_relative '../util/configuration'

module Notifications
  class PushOver
    
    attr_reader :configuration, :pushover
    def initialize
      @configuration = Util::Configuration.new.get(:pushover).verify(:app_token, :user_key)
    end

    def send(event, priority)
      event_file = Util::Event.new.get_event_file(event)

      Pushover::Message.new(
        token: @configuration['app_token'], user: @configuration['user_key'],
        title: "pg_backup - #{event_file['status']}",
        message: "#{event_file['description']} \n\n#{event_file['info']} \n\n#{event_file['schedule']}",
        priority: priority, expire: 3600, retry: 60
      ).push
    end
  end
end
