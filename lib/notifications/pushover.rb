require_relative '../configuration/env'
require_relative '../util/file'
require 'pushover'
require 'cronex'
require 'logger'

module Notifications
  class PushOver
    attr_reader :pushover

    def initialize
      @file = Util::File.new
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.get_key(:pushover)
      @database = Env::Env.new.get_key(:postgres)
    end

    def send(event)
      event_file = @file.event(event)

      @logger.info("Sending message to Pushover for event: #{event}")
      begin
        Pushover::Message.new(
          token: @env['app_token'], user: @env['user_key'],
          title: "pg_brm - #{event_file['status']}",
          message: "#{event_file['description']} \n\n#{event_file['info'].gsub('%s', databases)} \n\n#{event_file['schedule'].gsub('%s', cronex)}",
          priority: priority(event), expire: 3600, retry: 60
        ).push
      rescue StandardError => e
        @logger.error("Error sending message to Pushover \nERROR: #{e.message}")
        exit!
      end
    end

    private

    # set priority for pushover messages based on event
    def priority(event)
      case event
      when :backup, :restore
        0
      when :error, :s3
        2
      end
    end

    # search for all databases in @database hash and join them with a comma
    def databases
      @database.values.map { |db| db['database'] }.join(', ')
    end

    # cronex gem to parse cron expressions
    # @daily like expressions are not supported
    def cronex
      Cronex::ExpressionDescriptor.new(ENV.fetch('SCHEDULE', '0 0 * * *')).description
    end
  end
end
