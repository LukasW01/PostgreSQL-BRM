require 'pushover'

module Notifications
  class Pushover
    def initialize(configuration)
      @configuration = configuration
      @pushover = Pushover::Receipt.new(configuration.app_token, configuration.user_key)
    end

    def send(title, message, priority) 
      @pushover.Pushover::Message.new(message: message, title: title, priority: priority).push
    end

    private

    attr_reader :configuration, :pushover

    def app_token
      @app_token ||= @configuration.app_token
    end

    def user_key
      @user_key ||= @configuration.user_key
    end
  end
end
