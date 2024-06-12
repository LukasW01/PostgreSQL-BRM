require_relative '../configuration/env'
require_relative '../util/logger_delegator'
require_relative '../util/file'
require 'discordrb/webhooks'
require 'cronex'
require 'logger'

module Notifications
  class Discord
    attr_reader :discord

    def initialize
      @file = Util::File.new
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.get_key(:discord)
      @database = Env::Env.new.get_key(:postgres)
      @discord = Discordrb::Webhooks::Client.new(url: @env['webhook'].freeze)
    end

    def send(event)
      event_file = @file.event(event)

      @logger.info("Sending message to Discord for event: #{event}")
      begin
        @discord.execute do |builder|
          builder.username = 'Postgres-BRM'
          builder.add_embed do |embed|
            embed.title = 'pg_brm'
            embed.colour = 3_430_821
            embed.description = event_file['description']
            embed.add_field(name: 'Status:', value: event_file['status'])
            embed.add_field(name: 'Info:', value: event_file['info'].gsub('%s', databases))
            embed.add_field(name: 'Schedule:', value: event_file['schedule'].gsub('%s', cronex)) if event_file['schedule']
          end
        end
      rescue StandardError => e
        @logger.error("Error sending message to Discord \nERROR: #{e.message}")
        exit!
      end
    end

    private

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
