require 'dry/validation'

module Schema
  class MailgunSchema < Dry::Validation::Contract
    params do
      required(:mailgun).value(:hash) do
        required(:from).value(:string)
        required(:to).value(:string)
        required(:api_key).value(:string)
        required(:domain).value(:string)
        required(:mailgun_domain).value(:string)
      end
    end
    
    rule(:mailgun) do
      unless /^api\.(?:eu\.)?mailgun\.net$/.match?(value[:mailgun_domain])
        key([:mailgun, :mailgun_domain]).failure('mailgun_domain must be a valid api domain (api.mailgun.net or api.eu.mailgun.net)')
      end
    end
    
    rule(:mailgun) do
      unless /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,7}$/.match?(value[:domain])
        key([:mailgun, :domain]).failure('domain must be a valid domain (e.g example.com)')
      end      
    end
    
    rule(:mailgun) do
      unless /^\S+@\S+\.\S+$/.match?(value[:from])
        key([:mailgun, :from]).failure('from must be a valid email address (e.g. no-reply@example.com)')
      end
      unless /^\S+@\S+\.\S+$/.match?(value[:to])
        key([:mailgun, :to]).failure('to must be a valid email address (e.g. you@example.com)')
      end
    end
    
  end
end