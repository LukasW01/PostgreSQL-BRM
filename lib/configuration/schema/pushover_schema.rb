require 'dry/validation'

module Schema
  class PushoverSchema < Dry::Validation::Contract
    params do
      optional(:pushover).value(:hash) do
        optional(:user_key).value(:string)
        optional(:app_token).value(:string)
      end
    end
  end
end
