FROM ruby:alpine
ARG user=ruby
ENV SCHEDULE="0 0 * * *" TZ="Europe/Zurich" HEALTHCHECK_PORT=8080 

RUN apk update && apk add --no-cache postgresql-client postgresql && apk add --no-cache build-base libxml2-dev libxslt-dev tzdata
RUN wget -O /tmp/go-cron.tar.gz https://github.com/michaloo/go-cron/releases/download/v0.0.2/go-cron.tar.gz && tar xopf /tmp/go-cron.tar.gz -C /usr/local/bin/ && chmod a+x /usr/local/bin/go-cron

RUN adduser --disabled-password --gecos "" $user

WORKDIR /ruby
COPY . .
RUN chown -R $user:$user .
VOLUME ["/ruby/lib/backup", "/ruby/lib/log"]

USER $user
RUN bundle install

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["exec /usr/local/bin/go-cron -s \"$SCHEDULE\" -p \"$HEALTHCHECK_PORT\" -c \"bundler exec rake pg_brm:dump\""]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$HEALTHCHECK_PORT/" || exit 1
