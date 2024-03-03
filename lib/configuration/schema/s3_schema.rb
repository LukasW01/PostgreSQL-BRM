require 'dry/validation'

module Schema
  class S3Schema < Dry::Validation::Contract
    params do
      optional(:s3).value(:hash) do
        optional(:access_key_id).filled(:string)
        optional(:secret_access_key).filled(:string)
        optional(:endpoint).filled(:string)
        optional(:bucket).filled(:string)
        optional(:region).filled(:string)
      end
    end

    rule(:s3) do
      next if value.nil?

      key(%i[s3 endpoint]).failure('endpoint must be a valid url (e.g. https://s3.eu-west-1.amazonaws.com)') unless %r{https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_+.~#?&/=]*)}.match?(value[:endpoint])
    end
  end
end
