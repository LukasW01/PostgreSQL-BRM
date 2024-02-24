require 'discordrb/webhooks'
require 'cronex'
require_relative '../configuration/env'

module Notifications

  attr_reader :configuration, :discord
  class Discord
    def initialize
      @configuration = Env::Env.new.get_key(:discord)
      @database = Env::Env.new.get_key(:postgres)
      @discord = Discordrb::Webhooks::Client.new(url: @configuration['webhook'].freeze)
    end

    def send(event)
      event_file = get_event_file(event)

      @discord.execute do |builder|
        builder.username = 'Postgres-BRM'
        builder.add_embed do |embed|
          embed.title = 'pg_backup'
          embed.timestamp = Time.now
          embed.color = 3_430_821
          embed.description = event_file['description']
          embed.add_field(name: 'Status:', value: event_file['status'])
          embed.add_field(name: 'Info:', value: event_file['info'].gsub('%s', databases))
          embed.add_field(name: 'Schedule:', value: event_file['schedule'].gsub('%s', cronex))
        end
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
      Cronex::ExpressionDescriptor.new(ENV['SCHEDULE']).description
    end
  end
end
