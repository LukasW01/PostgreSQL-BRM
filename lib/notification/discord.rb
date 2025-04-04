require_relative '../configuration/env'
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
      @discord = Discordrb::Webhooks::Client.new(url: @env['webhook'].freeze)
      @notification = Notification.new
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
            embed.add_field(name: 'Info:', value: event_file['info'].gsub('%s', @notification.databases))
            embed.add_field(name: 'Schedule:', value: event_file['schedule'].gsub('%s', @notification.cronex)) if event_file['schedule']
          end
        end
      rescue StandardError => e
        @logger.error("Error sending message to Discord \nERROR: #{e.message}")
        exit!
      end
    end
  end
end
