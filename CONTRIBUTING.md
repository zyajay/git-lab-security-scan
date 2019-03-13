## Developer Certificate of Origin + License

By contributing to GitLab B.V., You accept and agree to the following terms and
conditions for Your present and future Contributions submitted to GitLab B.V.
Except for the license granted herein to GitLab B.V. and recipients of software
distributed by GitLab B.V., You reserve all right, title, and interest in and to
Your Contributions. All Contributions are subject to the following DCO + License
terms.

[DCO + License](https://gitlab.com/gitlab-org/dco/blob/master/README.md)

_This notice should stay as the first item in the CONTRIBUTING.md file._

## Issue tracker

To get support for your particular problem please use the
[getting help channels](https://about.gitlab.com/getting-help/).

The [GitLab EE issue tracker on GitLab.com][ee-tracker] is the right place for bugs and feature proposals about Security Products. 
Please use the ~"Secure" and ~"devops:secure" labels when opening a new issue to ensure it is quickly reviewed by the right people.

**[Search the issue tracker][ee-tracker]** for similar entries before
submitting your own, there's a good chance somebody else had the same issue or
feature proposal. Show your support with an award emoji and/or join the
discussion. 

Not all issues will be addressed and your issue is more likely to
be addressed if you submit a merge request which partially or fully solves
the issue. If it happens that you know the solution to an existing bug, please first
open the issue in order to keep track of it and then open the relevant merge
request that potentially fixes it.

[ee-tracker]: https://gitlab.com/gitlab-org/gitlab-ee/issues

## Adding support for new languages and frameworks

You can contribute and add support for new languages and frameworks
by creating a new Dependency Scanning (DS) analyzer:

1. Choose an open source library for your language.
1. Create a Docker image that is compatible with the DS Analyzer API.

DS Analyzer API:

- The entry point of the Docker image is a command line
that detects and analyzes compatible projects.
- It searches for compatible project in `$CI_PROJECT_DIR` and analyzes it.
- It generates an artifact named `gl-dependency-scanning-report.json` in `$CI_PROJECT_DIR`.
- It exits with the appropiate exit code. See below.

Exit codes:

- 0 if a compatible project has been found and successfully analyzed
- 2 if the arguments are invalid or when showing the help
- 3 if no compatible project has been found
- 1 if an error has occured

Note that the exit code is 0 when vulnerabilities are found.

You can implement an analyzer using the Go language
and the [common libary](https://gitlab.com/gitlab-org/security-products/analyzers/common).
This library provides three Go packages:
- [search](https://gitlab.com/gitlab-org/security-products/analyzers/common/tree/master/search) to search for compatible projects
- [issue](https://gitlab.com/gitlab-org/security-products/analyzers/common/tree/master/issue) to generate the JSON artifact
- [command](https://gitlab.com/gitlab-org/security-products/analyzers/common/tree/master/command) to create a command line with the sub-commands `search` and `convert`

You may have a look at the [bundler-audit analyzer](https://gitlab.com/gitlab-org/security-products/analyzers/bundler-audit)
to see how the common library is used.
