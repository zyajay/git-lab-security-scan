# Dependency Scanning Analyzers

## Overview

Dependency Scanning relies on underlying third party tools that are wrapped into what we call `Analyzers`.
An analyzer is a [dedicated project](https://gitlab.com/gitlab-org/security-products/analyzers) that wraps a particular tool to:
- expose its detection logic
- handle its execution
- convert its output to the common format

This is achieved by implementing the [common API](https://gitlab.com/gitlab-org/security-products/analyzers/common).

Dependency Scanning currently supports the following official analyzers:

- [bundler-audit](https://gitlab.com/gitlab-org/security-products/analyzers/bundler-audit)
- [gemnasium](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium)
- [gemnasium-maven](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium-maven)
- [gemnasium-python](https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium-python)
- [retire.js](https://gitlab.com/gitlab-org/security-products/analyzers/retire.js)

The Analyzers are published as Docker images that Dependency Scanning will use to launch dedicated containers for each analysis.

Dependency Scanning is pre-configured with a set of **default images** that are officially maintained by GitLab.

Users can also integrate their own **custom images**.

## Custom Analyzers

You can provide your own analyzers as a comma separated list of Docker images.
Here's how to add `analyzers/nugget` and `analyzers/perl` to the default images:

    DS_ANALYZER_IMAGES=analyzers/nugget,analyzers/perl

Please note that this configuration doesn't benefit from the integrated detection step.
Dependency Scanning has to fetch and spawn each Docker image to establish whether the custom analyzer can scan the source code.

## Default analyzers

### Use a Docker mirror

You can switch to a custom Docker registry
that provides the official analyzer images under a different prefix.
For instance, the following instructs Dependency Scanning to pull `my-docker-registry/gl-images/gemnasium`
instead of `registry.gitlab.com/gitlab-org/security-products/analyzers/gemnasium`:

    DS_ANALYZER_IMAGE_PREFIX=my-docker-registry/gl-images

Please note that this configuration requires that your custom registry provides images for all the official analyzers.

### Select specific analyers

You can select the official analyzers you want to run.
Here's how to enable `bundler-audit` and `gemnasium` while disabling all the other official analyzers:

    DS_DEFAULT_ANALYZERS="bundler-audit,gemnasium

### Disable all analyzers

Setting `DS_DEFAULT_ANALYZERS` to an empty string will disable all the default analyzers.

    DS_DEFAULT_ANALYZERS=""

## Analyzers Data

| Property \ Tool                       |      Gemnasium     |    bundler-audit   |     Retire.js      |
|---------------------------------------|:------------------:|:------------------:|:------------------:|
| severity                              |         :x:        | :white_check_mark: | :white_check_mark: |
| title                                 | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| file                                  | :white_check_mark: |      :warning:     | :white_check_mark: |
| start line                            |         :x:        |         :x:        |         :x:        |
| end line                              |         :x:        |         :x:        |         :x:        |
| external id (e.g. CVE)                | :white_check_mark: | :white_check_mark: |      :warning:     |
| urls                                  | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| internal doc/explanation              | :white_check_mark: |         :x:        |         :x:        |
| solution                              | :white_check_mark: | :white_check_mark: |         :x:        |
| confidence                            |         :x:        |         :x:        |         :x:        |
| affected item (e.g. class or package) | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| source code extract                   |         :x:        |         :x:        |         :x:        |
| internal id                           | :white_check_mark: |         :x:        |         :x:        |
| date                                  | :white_check_mark: |         :x:        |         :x:        |
| credits                               | :white_check_mark: |         :x:        |         :x:        |

- :white_check_mark: => we have that data
- :warning: => we have that data but it's partially reliable, or we need to extract that data from unstructured content
- :x: => we don't have that data or it would need to develop specific or inefficient/unreliable logic to obtain it.

The values provided by these tools are heterogeneous so they are sometimes normalized into common values (e.g. `severity`, `confidence`, etc).
This mapping usually happens in the analyzer's `convert` command.