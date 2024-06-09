FROM ruby:3.3-alpine3.20
ARG user=ruby
ARG GOCRONVER=v0.0.10
ARG TARGETOS
ARG TARGETARCH
ENV SCHEDULE="0 0 * * *" TZ="Europe/Zurich" HEALTHCHECK_PORT=8080

RUN apk update && apk add --no-cache postgresql-client postgresql && apk add --no-cache build-base libxml2-dev libxslt-dev tzdata && apk add ca-certificates curl && apk add ruby-full
RUN curl --fail --retry 4 --retry-all-errors -L https://github.com/prodrigestivill/go-cron/releases/download/$GOCRONVER/go-cron-$TARGETOS-$TARGETARCH-static.gz | zcat > /usr/local/bin/go-cron && chmod a+x /usr/local/bin/go-cron

RUN adduser --disabled-password --gecos "" $user

WORKDIR /ruby
COPY . .
RUN chown -R $user:$user .
VOLUME ["/ruby/lib/backup", "/ruby/lib/log"]

RUN echo "#!/bin/sh" > run.sh && echo "bundle exec rake pg_brm:dump" >> run.sh && chmod +x run.sh

RUN bundle install
USER $user

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["exec /usr/local/bin/go-cron -s \"$SCHEDULE\" -p \"$HEALTHCHECK_PORT\" -- /ruby/run.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
    CMD curl -f "http://localhost:$HEALTHCHECK_PORT/" || exit 1
