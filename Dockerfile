FROM registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium:2.3.0

ENV GEMNASIUM_CLI_PATH="/analyzer"
ENV GEMNASIUM_MAVEN_IMAGE="registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium-maven:2.4.0"
ENV GEMNASIUM_PYTHON_IMAGE="registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python:2.3.0"

RUN mkdir /app
WORKDIR /app
ADD . /app

SHELL ["/bin/ash", "-c"]
RUN apk add --no-cache docker ruby-bundler && \
	bundle install --without development test

ENTRYPOINT  ["/app/bin/run"]
