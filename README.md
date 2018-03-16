# GitLab Dependency Scanning

[![pipeline status](https://gitlab.com/gitlab-org/security-products/sast/badges/master/pipeline.svg)](https://gitlab.com/gitlab-org/security-products/sast/commits/master)
[![coverage report](https://gitlab.com/gitlab-org/security-products/sast/badges/master/coverage.svg)](https://gitlab.com/gitlab-org/security-products/sast/commits/master)

GitLab tool for running Dependency Security Scanning on provided project.

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
    `VERSION` can be replaced with the latest available release matching your GitLab version. See [Versioning](#versioning-and-release-cycle) for more details.

1. The results will be displayed and also stored in `gl-dependency-scanning-report.json`

**Why mounting the Docker socket?**

Some tools require to be able to launch Docker containers to scan your application. You can skip this but you won't benefit from all scanners.

### Environment variables

Dependency Scanning can be configured with environment variables, here is a list:

| Name                           | Function                                                                           |
|--------------------------------|------------------------------------------------------------------------------------|
| DEP_SCAN_DISABLE_REMOTE_CHECKS | Do not send any data to GitLab (Used in the dependency version checker, see below) |

## Development

### Running application

Build a Docker image locally:

```sh
docker build --no-cache --rm -t dep-scan .
```

Then run it:

```sh
docker run \
  --interactive --tty --rm \
  --volume /path/to/source/code:/code \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  dep-scan /code
```

### Running tests

Launch a ruby container:
```sh
docker run \
  --interactive --tty --rm \
  --volume "$PWD":/app \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  ruby bash
```

Then run the tests:

```sh
cd /app
bundle install
bundle exec rspec spec
```

You can skip long integration tests by excluding the integration tag:

```sh
bundle exec rspec spec --tag ~integration
```

## Supported languages and package managers

The following table shows which languages and package managers are supported and which tools are used.

| Language (package managers)                                                 | Scan tool                                                                                                                         |
|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| JavaScript ([npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/en/)) | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium), [Retire.js](https://retirejs.github.io/retire.js)         |
| Python ([pip](https://pip.pypa.io/en/stable/))                              | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium)                                                            |
| Ruby ([gem](https://rubygems.org/))                                         | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium), [bundler-audit](https://github.com/rubysec/bundler-audit) |
| Java ([Maven](https://maven.apache.org/))                                   | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium),                                                           |
| PHP ([Composer](https://getcomposer.org/))                                  | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium)                                                            |

## Remote checks

While some tools pull a local database to check vulnerabilities, some others require to send data to GitLab central servers to analyze them.
You can disable these tools by using the `DEP_SCAN_DISABLE_REMOTE_CHECKS` [environment variable](https://docs.gitlab.com/ee/ci/variables/README.html#gitlab-ci-yml-defined-variables).

Here is the list of tools that are doing such remote checks and what kind of data they send:

**Gemnasium**

* Gemnasium scans the dependencies of your project locally and sends a list of packages to GitLab central servers.
* The servers return the list of known vulnerabilities for all the versions of these packages
* Then the client picks up the relevant vulnerabilities by comparing with the versions of the packages that are used by the project.

Gemnasium does *NOT* send the exact package versions your project relies on.

## Versioning and release process

Please check the [Release Process documentation](./docs/release_process.md).

# Contributing

If you want to help and extend the list of supported scanners, read the
[contribution guidelines](CONTRIBUTING.md).
