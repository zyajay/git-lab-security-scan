FROM ruby:2.3
RUN mkdir /app
WORKDIR /app
ADD . /app

# Install NPM version 6
RUN apt-get update && apt-get install -y curl software-properties-common && \
  (curl -sL https://deb.nodesource.com/setup_10.x | bash -) && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

RUN bundle install --without development test

ENTRYPOINT  ["/app/bin/run"]
