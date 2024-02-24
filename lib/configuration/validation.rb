require 'yaml'
require 'dry-schema'

module Configuration 
  class Validation < Dry::Schema::Params
    def db_schema
      Dry::Validation.Schema do
        required(:postgres) do
          hash do
            required(:host).filled(:string)
            required(:port).filled(:integer)
            required(:database).filled(:string)
            required(:user).filled(:string)
            required(:password).filled(:string)
          end
        end
      end
    end

    def s3_schema
      Dry::Validation.Schema do
        required(:s3) do
          hash do
            required(:access_key_id).filled(:string)
            required(:secret_access_key).filled(:string)
            required(:region).filled(:string)
            required(:provider).filled(:string)
            required(:endpoint).filled(:uri)
          end
        end
      end
    end
    
    def mailgun_schema
      Dry::Validation.Schema do
        required(:mailgun) do
          hash do
            required(:from).filled(:mail)
            required(:to).filled(:mail)
            required(:api_key).filled(:string)
            optional(:mailgun_domain).filled(:string).default('api.mailgun.org')
            required(:domain).filled(:string)
          end
        end
      end
    end

    def pushover_schema
      Dry::Validation.Schema do
        required(:pushover) do
          hash do
            required(:app_token).filled(:string)
            required(:user_key).filled(:string)
          end
        end
      end
    end

    def discord_schema
      Dry::Validation.Schema do
        required(:discord) do
          hash do
            required(:webhook_url).filled(:uri)
          end
        end
      end
    end
  end
end
