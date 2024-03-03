require 'dry/validation'

module Schema
  class DiscordSchema < Dry::Validation::Contract
    params do
      optional(:discord).value(:hash) do
        optional(:webhook).value(:string)
      end
    end

    rule(:discord) do
      key(%i[discord webhook]).failure('discord webhook must be a valid webhook url') unless value && %r{https://discord.com/api/webhooks/([^/]+)/([^/]+)}.match?(value[:webhook])
    end
  end
end
