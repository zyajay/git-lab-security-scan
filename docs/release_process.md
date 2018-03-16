# GitLab Dependency Scanning release process

GitLab Dependency Scanning follows the versioning of GitLab (`MAJOR.MINOR` only) and is available as a Docker image tagged with `MAJOR-MINOR-stable`.

E.g. For GitLab `10.5.x` you'll need to run the `10-5-stable` GitLab Dependency Scanning image:

    registry.gitlab.com/gitlab-org/security-products/dependency-scanning:10-5-stable

This ensures GitLab Dependency Scanning stays compatible with the GitLab instance it runs on and generates the expected report while allowing flexibility to provide patches without having to upgrade the whole GitLab project.

Please note that the Auto-DevOps feature automatically uses the correct version. If you have your own `.gitlab-ci.yml` in your project, please ensure you are up-to-date with the [Auto-DevOps template](https://gitlab.com/gitlab-org/gitlab-ci-yml/blob/master/Auto-DevOps.gitlab-ci.yml).

## Release Process

A Release Manager is assigned to each release and is responsible for:

- following the release process to generate the new version of related projects (binaries, docker images, etc.)
- following the QA process to ensure we ship fully functionnal software

Release Manager must use the provided scripts to generate the issues corresponding to the release process.

* `./scripts/release_issue.rb`
* `./scripts/qa_issue.rb`

### On 7th of the month (working day, prior to 23:59 pacific):

> 7th of the month is the date of the feature freeze and the first RC of GitLab is created on the 8th. When the GitLab `X.Y.0-RC1` is deployed for QA on the 8th, the CI server looks for the matching `X-Y-stable` Docker image of GitLab Dependency Scanning.


* prepare the release: complete changelog/documentation with missing entries for `X-Y-stable`
* create the `X-Y-stable` branch from `master`. This generates the `X-Y-stable` Docker image, having it ready for GitLab CE/EE RC1 created on the 8th.
* bump version number to next release (`X.Y+1`) in the [version file](../VERSION) and add the corresponding [changelog section](../CHANGELOG.md) to ease upcoming Merge Requests (on `master` branch)

### After the 7th and until next month:

To submit a feature for next release (`X.Y+1`):
  - start working from the `master` branch and open an MR against `master`
  - update the changelog for next release `X.Y+1`
  - merge the feature branch into `master`. Nothing is published yet, it will be on the next release (`X.Y+1`)

To submit a bugfix for `X.Y`:
  - if bug exists in the `master` branch:
    - start working from the `master` branch and open an MR against `master`
    - update the changelog for release `X.Y`
    - assign the MR to a milestone related to the oldest version in which the bug exists
    - if a merge request is to be picked into more than one release it will need one
      `Pick into MAJOR.MINOR` label per release where the merge request should be back-ported
      to.
    - merge the feature branch into `master`
    - cherry-pick the merge commit to each `MAJOR-MINOR-stable` branch corresponding
      to the `Pick into MAJOR.MINOR` labels assigned starting from the oldest up to the latest release.
      Each update pushed on `MAJOR-MINOR-stable` release branches generates a new Docker image
      that is released immediately by overriding the corresponding `MAJOR-MINOR-stable` image tag.
      Remove each label once picked into their respective stable branches
  - if bug doesn't exist in the `master` branch:
    - start work from `MAJOR-MINOR-stable` of the most recent version where the
      bug exists and open an MR against this branch
    - assign the MR to a milestone related to the oldest version in which the bug exists
    - if a merge request is to be picked into more than one release it will need one
      `Pick into MAJOR.MINOR` label per release where the merge request should be back-ported
      to.
    - merge the feature branch into the assigned `MAJOR-MINOR-stable` branch. This generates a new Docker image
      that is released immediately by overriding the corresponding `MAJOR-MINOR-stable` image tag.
    - cherry-pick the merge commit to each `MAJOR-MINOR-stable` branch corresponding
      to the `Pick into MAJOR.MINOR` labels assigned starting from the oldest up to the latest release.
      Each update pushed on `MAJOR-MINOR-stable` release branches generates a new Docker image
      that is released immediately by overriding the corresponding `MAJOR-MINOR-stable` image tag.
      Remove each label once picked into their respective stable branches

---
