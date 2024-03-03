require 'dry/validation'

module Schema
  class MailgunSchema < Dry::Validation::Contract
    params do
      optional(:mailgun).value(:hash) do
        optional(:from).value(:string)
        optional(:to).value(:string)
        optional(:api_key).value(:string)
        optional(:domain).value(:string)
        optional(:mailgun_domain).value(:string)
      end
    end

    rule(:mailgun) do
      if value
        key(%i[mailgun mailgun_domain]).failure('mailgun_domain must be a valid api domain (api.mailgun.net or api.eu.mailgun.net)') unless value && /^api\.(?:eu\.)?mailgun\.net$/.match?(value[:mailgun_domain])
      end
    end

    rule(:mailgun) do
      if value
        key(%i[mailgun domain]).failure('domain must be a valid domain (e.g example.com)') unless value && /^[a-z0-9]+([-.][a-z0-9]+)*\.[a-z]{2,7}$/.match?(value[:domain])
      end
    end

    rule(:mailgun) do
      if value
        key(%i[mailgun from]).failure('from must be a valid email address (e.g. no-reply@example.com)') unless value && /^\S+@\S+\.\S+$/.match?(value[:from])
        key(%i[mailgun to]).failure('to must be a valid email address (e.g. you@example.com)') unless value && /^\S+@\S+\.\S+$/.match?(value[:to])
      end
    end
  end
end
