require 'dry/validation'

module Schema
  class CryptSchema < Dry::Validation::Contract
    params do
      required(:crypt).value(:hash) do
        required(:public_key).filled(:string)
        required(:private_key).filled(:string)
      end
    end

    rule(:crypt) do
      key(%i[crypt public_key]).failure('key must be length of 32') if values[:crypt][:public_key].size != 32
    end

    rule(:crypt) do
      key(%i[crypt private_key]).failure('key must be length of 32') if values[:crypt][:private_key].size != 32
    end
  end
end
