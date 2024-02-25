require 'dry/validation'

module Schema
  class DiscordSchema < Dry::Validation::Contract
    params do
      required(:discord).value(:hash) do
        required(:webhook).value(:string)
      end
    end

    rule(:discord) do
      unless /https:\/\/discord.com\/api\/webhooks\/([^\/]+)\/([^\/]+)/.match?(value[:webhook])
        key([:discord, :webhook]).failure('discord webhook must be a valid webhook url')
      end
    end
  end
end