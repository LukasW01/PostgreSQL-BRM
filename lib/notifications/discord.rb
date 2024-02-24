require 'discordrb/webhooks'
require_relative '../util/guration/configuration'

module Notifications

  attr_reader :configuration, :discord
  class Discord
    def initialize
      @discord = Discordrb::Webhooks::Client.new(url: @configuration['webhook'].freeze)
      @configuration = configuration.get_key(:discord).verify(:webhook)
      @database = configuration.get_key(:postgres).verify(:database)
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
          embed.add_field(name: 'Info:', value: event_file['info'].replace('%s', @database['database']))
          embed.add_field(name: 'Schedule:', value: event_file['schedule'].replace('%s', cronex.description))
        end
      end
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
