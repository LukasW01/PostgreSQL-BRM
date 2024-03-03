require 'dry/validation'

module Schema
  class DiscordSchema < Dry::Validation::Contract
    params do
      optional(:discord).value(:hash) do
        optional(:webhook).value(:string)
      end
    end

    rule(:discord) do
      next if value.nil?

      key(%i[discord webhook]).failure('discord webhook must be a valid webhook url') unless %r{https://discord.com/api/webhooks/([^/]+)/([^/]+)}.match?(value[:webhook])
    end
  end
end
