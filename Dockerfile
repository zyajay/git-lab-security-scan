FROM ruby:2.3
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN bundle install --without development test

ENTRYPOINT  ["/app/bin/run"]
