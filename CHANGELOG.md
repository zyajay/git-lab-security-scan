# GitLab Dependency Scanning changelog

## v2.1.3
- Fix unstable vulnerabilities ordering

## v2.1.2
- Fix `null` vulnerabilities instead of empty JSON array

## v2.1.1
- Fix merging of remediations

## v2.1.0
- Add `remediations` field to the reports

## v2.0.0
- Switch to new report syntax with `version` field

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
