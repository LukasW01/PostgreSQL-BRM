require 'discordrb/webhooks'
require 'json'

module Notifications
  class Discord
    def initialize(configuration)
      @configuration = configuration
      @discord = Discordrb::Webhooks::Client.new(url: configuration.url.freeze)
    end

    def send(event)
      result = get_event_files(event)

      @discord.execute do |builder|
        builder.add_embed do |embed|
          builder.username = 'Postgres-BRM'
          embed.title = 'pg_backup'
          embed.timestamp = Time.now
          embed.color = 3_430_821
          embed.description = result['description']
          embed.add_field(name: 'Status:', value: result['status'])
          embed.add_field(name: 'Info:', value: result['info'])
        end
      end
    end

    private

    attr_reader :configuration, :discord

    def url
      @url ||= @configuration.url
    end

    def get_event_files(event)
      @event = event
      JSON.parse(File.read('data/event.json')).fetch(@event).first.to_s
    end
  end
end
