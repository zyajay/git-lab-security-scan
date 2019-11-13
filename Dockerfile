FROM registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium:2.3.0
ENV GEMNASIUM_PATH="/analyzer"

RUN mkdir /app
WORKDIR /app
ADD . /app

SHELL ["/bin/ash", "-c"]
RUN apk add --no-cache ruby-bundler && \
	bundle install --without development test

ENTRYPOINT  ["/app/bin/run"]
