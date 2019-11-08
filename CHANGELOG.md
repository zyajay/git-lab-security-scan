# GitLab Dependency Scanning changelog

## v1.5.0
- Use common library v2 and analyzers v2 to generate v1 reports

## v1.4.4
- Fix `null` report instead of empty JSON array when no vulnerabilities

## v1.4.3
- Fix missing images gemnasium-python and gemnasimum-maven

## v1.4.2
- Fix missing build arg for `DS_ANALYZER_IMAGE_TAG`

## v1.4.1
- Restore removal of duplicated vulnerabilities

## v1.4.0
- Introduce customizable analyzers based on Docker images

## v1.3.0
- Vulnerabilities reported by Gemnasium now include a solution.

## v1.2.0
- Fix dependency scanning ignoring the variable `DEP_SCAN_DISABLE_REMOTE_CHECKS`.

## v1.1.0
- Fix missing cve value for some vulnerabilities (frontend workaround)

## v1.0.0
- Initial release
