require 'mailgun-ruby'
require_relative '../configuration/env'

module Notifications
  class MailGun

    attr_reader :configuration, :mailgun
    def initialize
      @configuration = Env.new.get_key(:mailgun)
      @database = Env.new.get_key(:postgres)
      @mailgun = Mailgun::Client.new(@configuration['api_key'], @configuration['mailgun_domain'])
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
          text: "#{event_files['description']} \n\n#{event_files['info'].gsub('%s', databases)} \n\n#{event_files['schedule'].gsub('%s', cronex)}" 
        }
      )
    end
    
    private

    # load event.yaml file and return the event hash
    def get_event_file(event)
      yaml = {}
      yaml.merge!(Hash[YAML::load(open("data/event.yaml")).map { |k, v| [k.to_sym, v] }])[event.to_sym]
    end

    # search for all databases in @database hash and join them with a comma
    def databases
      @database.values.map { |db| db['database'] }.join(', ')
    end

    # cronex gem to parse cron expressions
    # @daily like expressions are not supported
    def cronex
      #Cronex::ExpressionDescriptor.new(ENV['SCHEDULE']).description
      Cronex::ExpressionDescriptor.new("0 0 0 0 1").description
    end
  end
end
