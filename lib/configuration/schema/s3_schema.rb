require 'dry/validation'

module Schema
  class S3Schema < Dry::Validation::Contract
    params do
      required(:s3).value(:hash) do
        required(:access_key_id).filled(:string)
        required(:secret_access_key).filled(:string)
        required(:provider).filled(:string)
        required(:region).filled(:string)
        required(:endpoint).filled(:string)
      end
    end

    rule(:s3) do
      unless /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_\+.~#?&\/\/=]*)/.match?(value[:endpoint])
        key([:s3, :endpoint]).failure('endpoint must be a valid url (e.g. https://s3.eu-west-1.amazonaws.com)')
      end
    end
  end
end
