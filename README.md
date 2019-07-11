# GitLab Dependency Scanning

[![pipeline status](https://gitlab.com/gitlab-org/security-products/dependency-scanning/badges/master/pipeline.svg)](https://gitlab.com/gitlab-org/security-products/dependency-scanning/commits/master)
[![coverage report](https://gitlab.com/gitlab-org/security-products/dependency-scanning/badges/master/coverage.svg)](https://gitlab.com/gitlab-org/security-products/dependency-scanning/commits/master)

GitLab tool for running Dependency Security Scanning on given project.
It's written in Go using
the [common library](https://gitlab.com/gitlab-org/security-products/analyzers/common)
shared by SAST, Dependency Scanning and their analyzers.

## How to use

1. `cd` into the directory of the application you want to scan
1. Run the Docker image:

    ```sh
    docker run \
      --interactive --tty --rm \
      --volume "$PWD":/code \
      --volume /var/run/docker.sock:/var/run/docker.sock \
      registry.gitlab.com/gitlab-org/security-products/dependency-scanning:${VERSION:-latest} /code
    ```

    `VERSION` can be replaced with the latest available release matching your GitLab version. See [Versioning](#versioning-and-release-process) for more details.

1. The results will be displayed and also stored in `gl-dependency-scanning-report.json`

**Why mounting the Docker socket?**

Some tools require to be able to launch Docker containers to scan your application. You can skip this but you won't benefit from all scanners.

## Settings

The settings are documented in [GitLab CE](https://docs.gitlab.com/ee/user/application_security/dependency_scanning/index.html).

## Development

### Build project

Go 1.11 or higher is required to build Dependency Scanning. Go modules must be enabled.

```sh
GO111MODULE=on go build
```

### Run locally

To run the command locally and perform the scan on `/tmp/code`:

```sh
CI_PROJECT_DIR=/tmp/code ./dependency-scanning
```

### Integration tests

To run the integration tests:

```sh
./test.sh
```

## Versioning and release process

Please check the [Release Process documentation](https://gitlab.com/gitlab-org/security-products/release/blob/master/docs/release_process.md).

# Contributing

If you want to help and extend the list of supported scanners, read the
[contribution guidelines](CONTRIBUTING.md).
