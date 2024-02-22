require 'discordrb/webhooks'
require_relative '../util/event'
require_relative '../util/configuration'

module Notifications

  attr_reader :configuration, :discord
  class Discord
    def initialize
      @configuration = Util::Configuration.new.get(:discord).verify(:webhook)
      @discord = Discordrb::Webhooks::Client.new(url: @configuration['webhook'].freeze)
    end

    def send(event)
      event_file = Util::Event.new.get_event_file(event)

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
  end
end
