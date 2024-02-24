require 'pushover'
require_relative '../util/guration/configuration'

module Notifications
  class PushOver
    
    attr_reader :configuration, :pushover
    def initialize
      @configuration = configuration.get_key(:pushover)
      @database = configuration.get_key(:postgres)
    end

    def send(event, priority)
      event_file = get_event_file(event)

      Pushover::Message.new(
        token: @configuration['app_token'], user: @configuration['user_key'],
        title: "pg_backup - #{event_file['status']}",
        message: "#{event_file['description']} \n\n#{event_file['info'].replace('%s', @database['database'])} \n\n#{event_file['schedule'].replace('%s', cronex.description)}",
        priority: priority, expire: 3600, retry: 60
      ).push
    end
    
    private

    def get_event_file(event)
      yaml = {}
      yaml.merge!(Hash[YAML::load(open("data/event.yaml")).map { |k, v| [k.to_sym, v] }])[event.to_sym]
    end

    def cronex
      @cronex ||= Cronex::ExpressionDescriptor.new(ENV['SCHEDULE'])
    end
    
    def configuration
      @configuration ||= Util::Configuration.new
    end
  end
end
