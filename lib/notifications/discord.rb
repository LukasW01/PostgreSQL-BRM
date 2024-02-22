require 'discordrb/webhooks'
require 'json'

module Notifications

  attr_reader :configuration, :discord
  class Discord
    def initialize
      @configuration = Util::Configuration.new.get(:discord)
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
          embed.add_field(name: 'Info:', value: event_file['info'])
        end
      end
    end

    private

    def get_event_file(event)
      yaml = {}
      yaml.merge!(Hash[YAML::load(open("data/event.yaml")).map { |k, v| [k.to_sym, v] }])[event.to_sym]
    end
  end
end
