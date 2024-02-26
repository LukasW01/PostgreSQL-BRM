require_relative '../configuration/env'
require_relative '../util/file'
require 'cronex'
require 'logger'
require 'mailgun-ruby'

module Notifications
  class MailGun
    attr_reader :env, :mailgun

    def initialize
      @file = Util::File.new
      @env = Env::Env.new.get_key(:mailgun)
      @database = Env::Env.new.get_key(:postgres)
      @mailgun = Mailgun::Client.new(@env['api_key'], @env['mailgun_domain'])
      @logger = Logger.new('log/ruby.log')
    end

    # Send an email through Mailgun.
    # Docs: https://github.com/mailgun/mailgun-ruby/tree/master/docs
    def send(event)
      event_files = @file.event(event)

      @logger.info("Sending message to Mailgun for event: #{event}")
      begin
        @mailgun.send_message(
          @env['domain'],
          {
            from: "Postgres-BRM <#{@env['from']}>", to: @env['to'],
            subject: "pg_backup - #{event_files['status']}",
            text: "#{event_files['description']} \n\n#{event_files['info'].gsub('%s', databases)} \n\n#{event_files['schedule'].gsub('%s', cronex)}"
          }
        )
      rescue StandardError => e
        @logger.error("Error sending E-Mail with Mailgun-API for event: #{event}")
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
      Cronex::ExpressionDescriptor.new(ENV.fetch('SCHEDULE', nil)).description
    rescue StandardError
      Cronex::ExpressionDescriptor.new(@file.app('schedule')).description
    end
  end
end
