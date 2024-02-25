require 'dry/validation'

module Schema
  class S3Schema < Dry::Validation::Contract
    params do
      required(:s3).value(:hash) do
        required(:access_key_id).filled(:string)
        required(:secret_access_key).filled(:string)
        required(:endpoint).filled(:string)
        required(:bucket).filled(:string)
        required(:region).filled(:string)
      end
    end

    rule(:s3) do
      key(%i[s3 endpoint]).failure('endpoint must be a valid url (e.g. https://s3.eu-west-1.amazonaws.com)') unless %r{https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_+.~#?&//=]*)}.match?(value[:endpoint])
    end
  end
end
