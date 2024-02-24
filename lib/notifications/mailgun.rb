require 'mailgun-ruby'
require_relative '../util/guration/configuration'
require 'dry/schema'

module Notifications
  class MailGun

    attr_reader :configuration, :mailgun
    def initialize
      @mailgun = Mailgun::Client.new(@configuration['api_key'], @configuration['mailgun_domain'])
      @configuration = configuration.get_key(:mailgun)
      @database = configuration.get_key(:postgres)
    end

    # Send an email through Mailgun.
    # Docs: https://github.com/mailgun/mailgun-ruby/tree/master/docs
    def send(event)
      event_files = get_event_file(event) 
        
      @mailgun.send_message(
        @configuration['domain'],
        {
          from: "Postgres-BRM <#{@configuration['from']}>", to: @configuration['to'],
          subject: "pg_backup - #{event_files['status']}",
          text: "#{event_files['description']} \n\n#{event_files['info'].replace('%s', @database['database'])} \n\n#{event_files['schedule'].replace('%s', cronex.description)}" 
        }
      )
    end
    
    private

    def get_event_file(event)
      yaml = {}
      yaml.merge!(Hash[YAML::load(open("data/event.yaml")).map { |k, v| [k.to_sym, v] }])[event.to_sym]
    end

    def cronex
      @cronex ||= Cronex::ExpressionDescriptor.new(ENV['SCHEDULE'])
    end

    def configuration
      @configuration ||= Util::Configuration.new
    end
  end
end
