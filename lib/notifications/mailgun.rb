require_relative '../configuration/env'
require_relative '../util/file'
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
      @database = Env::Env.new.get_key(:postgres)
      @mailgun = Mailgun::Client.new(@env['api_key'], @env['mailgun_domain'])
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
            text: "#{event_file['description']} \n\n#{event_file['info'].gsub('%s', databases)} \n\n#{event_file['schedule']&.gsub('%s', cronex)}"
          }
        )
      rescue StandardError => e
        @logger.error("Error sending E-Mail with Mailgun-API \nERROR: #{e.message}")
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
