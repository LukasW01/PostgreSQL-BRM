require 'mailgun-ruby'

module Notifications
  class Mailgun
    def initialize
      @configuration = configuration
      @mailgun = Mailgun::Client.new(configuration.api_key, configuration.domain)
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
      result = get_event_files(event)

      @mailgun.send_message(
        'www.wigger.one',
        { from: "Postgres-BRM <#{configuration.from}>", to: configuration.to, subject: "pg_backup - #{result['status']}", text: "#{result['description']} \n\n#{result['info']} \n\n#{result['schedule']}" }
      )
    end

    private

    attr_reader :configuration, :mailgun

    def api_key
      @api_key ||= @configuration.api_key
    end

    def domain
      @domain ||= @configuration.domain
    end

    def get_event_files(event)
      @event = event
      JSON.parse(File.read('data/event.json')).fetch(@event).first.to_s
    end
  end
end
