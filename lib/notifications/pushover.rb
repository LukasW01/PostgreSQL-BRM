require 'pushover'

module Notifications
  class Pushover
    def initialize()
      @configuration = configuration
    end

    def send(event, priority)
      result = get_event_file(event)

      Pushover::Message.new(token: configuration.token, user: configuration.user_token, title: "pg_backup - #{result['status']}", message: "#{result['description']} \n\n#{result['info']} \n\n#{result['schedule']}", priority: priority, expire: 3600, retry: 60).push
    end

    private

    attr_reader :configuration, :pushover

    def token
      @app_token ||= @configuration.app_token
    end

    def user_key
      @user_key ||= @configuration.user_key
    end

    def get_event_file(event)
      @event = event
      JSON.parse(File.read('data/event.json')).fetch(@event)
    end
  end
end
