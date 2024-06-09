# PostgreSQL BRM

A Ruby-based PostgreSQL backup and restore manager that safely stores your database dumps in an S3 bucket and provides notifications via Discord webhooks, Pushover and Mailgun.

![rake pg_brm:dump](data/dump.png)

![rake pg_brm:restore](data/restore.png)

## Getting Started

Install the dependencies:

```bash
bundler install
```

Expecuted the following rake-tasks to dump and restore the database:

```bash
# dump the database
bundler exec rake pg_brm:dump

# restore the database
bundler exec rake pg_brm:restore
```

## Docker

The PostgreSQL BRM is available as a Docker image. The image will be periodically dump the database and store the dump in an S3 bucket (if configured). 

Note: Configuration is done via environment variables and a `env.yaml` file. The `env.yaml` file is mounted into the container. 

```yaml
---
version: "3.8"

services:
    postgres:
        image: docker.io/postgres:16-alpine
        restart: unless-stopped
        networks:
        - db
        volumes:
        - ./db/:/var/lib/postgresql/data:Z
        environment:
        - POSTGRES_DB=db
        - POSTGRES_USER=user
        - POSTGRES_PASSWORD=password
        labels:
        - io.containers.autoupdate=registry

    pg_brm:
        image: ghcr.io/lukasw01/postgresql_brm:latest
        container_name: pg_brm
        restart: unless-stopped
        networks:
        - db
        volumes:
        - ./env.yaml:/ruby/env.yaml:Z
        - ./backup/:/ruby/lib/backup:Z
        - ./log/:/ruby/lib/log:Z
        environment:
        - TZ=Europe/Zurich # default
        - SCHEDULE=0 0 * * * # default (no @daily like expression supported)
        labels:
        - io.containers.autoupdate=registry

networks:
  db:
    external: true
```

## Configuration

Create a `env.yaml` file and fill in the required environment variables. You can use the [env.example.yaml](https://gitlab.com/LukasW01/postgresql-brm/-/blob/main/env.example.yaml) as a template.

If a `env.yaml` file is not present, the PostgreSQL BRM will raise an error and exit. The configuration file is required to run the PostgreSQL BRM and is getting validated when different modules are getting initialized. The only required environment variable is `postgres`. Other environment variables are optional and can be omitted.

```yaml
postgres: 
  db:
    host: "localhost"
    port: 5432
    database: "postgres"
    user: "root"
    password: ""
```

## License

This program is licensed under the MIT-License. See the "LICENSE" file for more information