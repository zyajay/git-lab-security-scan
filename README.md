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

Dependency Scanning can be configured using environment variables.

### Docker images

| Environment variable         | Function |
|------------------------------|----------|
| DS_ANALYZER_IMAGES           | Comma separated list of custom images. Default images are still enabled.|
| DS_ANALYZER_IMAGE_PREFIX     | Override the name of the Docker registry providing the default images (proxy). |
| DS_ANALYZER_IMAGE_TAG        | Override the Docker tag of the default images. |
| DS_DEFAULT_ANALYZERS         | Override the names of default images. |
| DS_PULL_ANALYZER_IMAGES      | Pull the images from the Docker registry (set to 0 to disable) |

Read more about [customizing analyzers](./docs/analyzers.md#custom-analyzers).

### Remote checks

| Name                           | Function                                                                           |
|--------------------------------|------------------------------------------------------------------------------------|
| DS_DISABLE_REMOTE_CHECKS       | Do not send any data to GitLab (Used in the dependency version checker, see below) |
| DEP_SCAN_DISABLE_REMOTE_CHECKS | Deprecated. Renamed to `DS_DISABLE_REMOTE_CHECKS `                                 |

### Timeouts

| Environment variable                 | Function |
|--------------------------------------|----------|
| DS_DOCKER_CLIENT_NEGOTIATION_TIMEOUT | Time limit for Docker client negotiation |
| DS_PULL_ANALYZER_IMAGE_TIMEOUT       | Time limit when pulling the image of an analyzer |
| DS_RUN_ANALYZER_TIMEOUT              | Time limit when running an analyzer |

Timeouts are parsed using Go's [`ParseDuration`](https://golang.org/pkg/time/#ParseDuration).
Valid time units are "ns", "us" (or "µs"), "ms", "s", "m", "h".
Examples: "300ms", "1.5h" or "2h45m".

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


## Supported languages and package managers

The following table shows which languages and package managers are supported and which tools are used.

| Language (package managers)                                                 | Scan tool                                                                                                                                 | Introduced in GitLab Version |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| JavaScript ([npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/en/)) | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium/general), [Retire.js](https://retirejs.github.io/retire.js)         | 10.5 |
| Python ([pip](https://pip.pypa.io/en/stable/))                              | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium/general)                                                            | 10.5 |
| Ruby ([gem](https://rubygems.org/))                                         | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium/general), [bundler-audit](https://github.com/rubysec/bundler-audit) | 10.5 |
| Java ([Maven](https://maven.apache.org/))                                   | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium/general),                                                           | 10.5 |
| PHP ([Composer](https://getcomposer.org/))                                  | [gemnasium](https://gitlab.com/gitlab-org/security-products/gemnasium/general)                                                            | 10.5 |

## Remote checks

While some tools pull a local database to check vulnerabilities, some others require sending data to GitLab central servers to analyze them.
You can disable these tools by using the `DS_DISABLE_REMOTE_CHECKS` [environment variable](https://docs.gitlab.com/ee/ci/variables/README.html#gitlab-ci-yml-defined-variables).

Here is the list of tools that are doing such remote checks and what kind of data they send:

**Gemnasium**

* Gemnasium scans the dependencies of your project locally and sends a list of packages to GitLab central servers.
* The servers return the list of known vulnerabilities for all versions of these packages
* Then the client picks up the relevant vulnerabilities by comparing with the versions of the packages that are used by the project.

Gemnasium does *NOT* send the exact package versions your project relies on.

## Versioning and release process

Please check the [Release Process documentation](https://gitlab.com/gitlab-org/security-products/release/blob/master/docs/release_process.md).

# Contributing

If you want to help and extend the list of supported scanners, read the
[contribution guidelines](CONTRIBUTING.md).
