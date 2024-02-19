require 'mailgun-ruby'

module Notifications
  class Mailgun
    def initialize(configuration)
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
    def send(from:, to:, subject:, text:)
      @mailgun.send_message(
        from: from,
        to: to,
        subject: subject,
        text: text
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
    
  end
end