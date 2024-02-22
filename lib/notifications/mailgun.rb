require 'mailgun-ruby'
require_relative '../util/event'
require_relative '../util/configuration'

module Notifications
  class MailGun

    attr_reader :configuration, :mailgun
    def initialize
      @configuration = Util::Configuration.new.get(:mailgun).verify(:api_key, :mailgun_domain, :domain, :from, :to)
      @mailgun = Mailgun::Client.new(@configuration['api_key'], @configuration['mailgun_domain'])
    end

    # Send an email through Mailgun.
    # 
    # ```
    # Mailgun.new.send(
    #   from: 'configration.from',
    #   to: 'configration.to',
    #   subject: 'Hello world!',
    #   text: 'This is the body of the email'
    # )
    # ```
    def send(event)
      event_files = Util::Event.new.get_event_file(event) 
        
      @mailgun.send_message(
        @configuration['domain'],
        {
          from: "Postgres-BRM <#{@configuration['from']}>", to: @configuration['to'],
          subject: "pg_backup - #{event_files['status']}",
          text: "#{event_files['description']} \n\n#{event_files['info']} \n\n#{event_files['schedule']}" 
        }
      )
    end
  end
end
