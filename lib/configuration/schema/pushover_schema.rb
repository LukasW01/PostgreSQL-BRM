require 'dry/validation'

module Schema
  class PushoverSchema < Dry::Validation::Contract
    params do
      required(:pushover).value(:hash) do
        required(:user_key).value(:string)
        required(:app_token).value(:string)
      end
    end
  end
end
