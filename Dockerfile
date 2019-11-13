FROM registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium:2.3.0

SHELL ["/bin/ash", "-c"]
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN bundle install --without development test

ENTRYPOINT  ["/app/bin/run"]
