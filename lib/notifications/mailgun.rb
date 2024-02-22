require 'mailgun-ruby'

module Notifications
  class MailGun
    def initialize
      @configuration = Util::Configuration.new.get(:mailgun)
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
      event_files = get_event_file(event)

      @mailgun.send_message(
        @configuration['domain'],
        {
          from: "Postgres-BRM <#{@configuration['from']}>", to: @configuration['to'],
          subject: "pg_backup - #{event_files['status']}",
          text: "#{event_files['description']} \n\n#{event_files['info']} \n\n#{event_files['schedule']}" 
        }
      )
    end

    private

    attr_reader :configuration, :mailgun

    def get_event_file(event)
      yaml = {}
      yaml.merge!(Hash[YAML::load(open("data/event.yaml")).map { |k, v| [k.to_sym, v] }])[event.to_sym]
    end
  end
end
