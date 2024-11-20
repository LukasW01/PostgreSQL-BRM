require_relative '../configuration/env'
require_relative '../util/file'
require_relative 'notification'
require 'cronex'
require 'logger'
require 'mailgun-ruby'

module Notifications
  class MailGun
    attr_reader :mailgun

    def initialize
      @file = Util::File.new
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.get_key(:mailgun)
      @mailgun = Mailgun::Client.new(@env['api_key'], @env['mailgun_domain'])
      @notification = Notification.new
    end

    # Send an email through Mailgun.
    # Docs: https://github.com/mailgun/mailgun-ruby/tree/master/docs
    def send(event)
      event_file = @file.event(event)

      @logger.info("Sending message to Mailgun for event: #{event}")
      begin
        @mailgun.send_message(
          @env['domain'],
          {
            from: "Postgres-BRM <#{@env['from']}>", to: @env['to'],
            subject: "pg_brm - #{event_file['status']}",
            text: "#{event_file['description']} \n\n#{event_file['info'].gsub('%s', @notification.databases)} \n\n#{event_file['schedule']&.gsub('%s', @notification.cronex)}"
          }
        )
      rescue StandardError => e
        @logger.error("Error sending E-Mail with Mailgun-API \nERROR: #{e.message}")
        exit!
      end
    end
  end
end
