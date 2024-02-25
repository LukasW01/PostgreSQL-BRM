require 'dry/validation'
require 'dry/schema'

module Schema
  class PostgresSchema < Dry::Validation::Contract
    params do
      required(:postgres).value(:hash).each do
        schema do
          required(:host).filled(:string)
          required(:port).filled(:integer)
          required(:user).filled(:string)
          required(:password).filled(:string)
          required(:database).filled(:string)
        end
      end
    end
  end
end
