# PostgreSQL BRM

A Ruby-Based PostgreSQL Backup and Restore Manager designed to enable you to securely store your database dumps in an S3 Bucket, while also providing notifications via Discord Webhooks, Pushover, and Mailgun.

## Getting Started

Install the dependencies:

```bash
bundle install
```

Create a `env.yaml` file and fill in the required environment variables. You can use the [env.example.yaml](https://gitlab.com/LukasW01/postgresql-brm/-/blob/main/env.yaml.example) as a template.

```bash
# dump the database
bundler exec rake pg_brm:dump

# restore the database
bundler exec rake pg_brm:restore
```

## License

This program is licensed under the MIT-License. See the "LICENSE" file for more information