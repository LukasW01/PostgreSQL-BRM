require 'pushover'
require 'yaml'
require 'cronex'
require_relative '../configuration/env'

module Notifications
  class PushOver
    attr_reader :configuration, :pushover

    def initialize
      @configuration = Env.new.get_key(:pushover)
      @database = Env.new.get_key(:postgres)
      @logger = Logger.new('log/ruby.log')
    end

    def send(event, priority = 0)
      event_file = get_event_file(event)

      @logger.info("Sending message to Pushover for event: #{event}")
      begin
        Pushover::Message.new(
          token: @configuration['app_token'], user: @configuration['user_key'],
          title: "pg_backup - #{event_file['status']}",
          message: "#{event_file['description']} \n\n#{event_file['info'].gsub('%s', databases)} \n\n#{event_file['schedule'].gsub('%s', cronex)}",
          priority: priority, expire: 3600, retry: 60
        ).push
      rescue StandardError => e
        @logger.error("Error sending message to Pushover for event: #{event}")
        @logger.error(e.message)
        raise e
      end
    end

    private

    # load event.yaml file and return the event hash
    def get_event_file(event)
      yaml = {}
      yaml.merge!(Hash[YAML::load(open("data/event.yaml")).map { |k, v| [k.to_sym, v] }])[event.to_sym]
    end

    # search for all databases in @database hash and join them with a comma
    def databases
      @database.values.map { |db| db['database'] }.join(', ')
    end

    # cronex gem to parse cron expressions
    # @daily like expressions are not supported
    def cronex
      Cronex::ExpressionDescriptor.new(ENV['SCHEDULE']).description rescue Cronex::ExpressionDescriptor.new(@file.app('schedule')).description
    end
  end
end
