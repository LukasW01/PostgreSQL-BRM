require_relative '../configuration/env'
require 'yaml'
require 'discordrb/webhooks'
require 'cronex'
require 'logger'

module Notifications
  class Discord
    attr_reader :configuration, :discord

    def initialize
      @configuration = Env.new.get_key(:discord)
      @database = Env.new.get_key(:postgres)
      @discord = Discordrb::Webhooks::Client.new(url: @configuration['webhook'].freeze)
      @logger = Logger.new('log/ruby.log')
      @file = Util::File.new
    end

    def send(event)
      event_file = @file.event(event)

      @logger.info("Sending message to Discord for event: #{event}")
      begin
        @discord.execute do |builder|
          builder.username = 'Postgres-BRM'
          builder.add_embed do |embed|
            embed.title = 'pg_backup'
            embed.description = event_file['description']
            embed.add_field(name: 'Status:', value: event_file['status'])
            embed.add_field(name: 'Info:', value: event_file['info'].gsub('%s', databases))
            embed.add_field(name: 'Schedule:', value: event_file['schedule'].gsub('%s', cronex))
          end
        end
      rescue StandardError => e
        @logger.error("Error sending message to Discord for event: #{event}")
        @logger.error(e.message)
        raise e
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
      Cronex::ExpressionDescriptor.new(ENV['SCHEDULE']).description rescue Cronex::ExpressionDescriptor.new(@file.app('schedule')).description
    end
  end
end
