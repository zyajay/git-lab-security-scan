# GitLab Dependency Scanning changelog

## v2.7.0
- Add support for scanning `go` via `go.sum` (!58)

## v2.6.1
- Log when downloading, starting analyzers (!56)
- Suppress the progress message on pulling analyzer image (!56)

## v2.6.0
- Add `DS_PIP_VERSION` and `PIP_REQUIREMENTS_FILE` options in `gemnasium-python` (!54)
- Add support for scala/sbt in `gemnasium-maven` (!54)
- Add `BUNDLER_AUDIT_UPDATE_DISABLED` option in `bundler-audit` (!54)

## v2.5.0
- Add `build.gradle` support (!53)

## v2.4.0
- Add `setup.py` support (!40)

## v2.3.3
- Fix `DS_EXCLUDED_PATHS` not applied to dependency files (!35)

## v2.3.2
- Fix parsing of npm-shrinkwrap.json files

## v2.3.1
- Sort dependency files and dependencies when merging reports (!32)

## v2.3.0
- List the dependency files and their dependencies (!31)

## v2.2.0
- Add `DS_EXCLUDED_PATHS` option to exclude paths from report.

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
