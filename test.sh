#!/bin/sh

# Make it TAP compliant, see http://testanything.org/tap-specification.html
echo "1..4"

failed=0
step=1

got="test/fixtures/gl-dependency-scanning-report.json"
expect="test/expect/gl-dependency-scanning-report.json"

export DS_DEFAULT_ANALYZERS=${DS_DEFAULT_ANALYZERS:-"bundler-audit,retire.js,gemnasium"}
export DS_ANALYZER_IMAGE_TAG=${DS_ANALYZER_IMAGE_TAG:-"2"}
export DS_EXCLUDED_PATHS="ignored,*-excluded"

# Project found, artifact generated (bind mount)
desc="Generate expected artifact (bind mount, pull images)"
rm -f $got
CI_PROJECT_DIR="$PWD/test/fixtures" ./dependency-scanning

if test $? -eq 0 && diff -u $expect $got; then
  echo "ok $step - $desc"
else
  echo "not ok $step - $desc"
  failed=$((failed+1))
fi
step=$((step+1))
echo

# Project not found
desc="Exit with exit status 3 when no compatible analyzer can be found"
CI_PROJECT_DIR="$PWD/test/fixtures/unknown" DS_PULL_ANALYZER_IMAGES=0 ./dependency-scanning

if [ $? -eq 3 ]; then
  echo "ok $step - $desc"
else
  echo "not ok $step - $desc"
  failed=$((failed+1))
fi
step=$((step+1))
echo

# Project empty
desc="Exit with exit status 4 when the project directory is completely empty"
mkdir -p "$PWD/test/fixtures/empty"
CI_PROJECT_DIR="$PWD/test/fixtures/empty" DS_PULL_ANALYZER_IMAGES=0 ./dependency-scanning

if [ $? -eq 4 ]; then
  echo "ok $step - $desc"
else
  echo "not ok $step - $desc"
  failed=$((failed+1))
fi
step=$((step+1))
echo

# Project found, artifact generated (bind mount, no pull)
expect="test/expect/gl-dependency-scanning-report.no-remote-checks.json"
desc="Generate expected artifact w/o remote checks"
rm -f $got
CI_PROJECT_DIR="$PWD/test/fixtures" DS_PULL_ANALYZER_IMAGES=0 ./dependency-scanning

if test $? -eq 0 && diff -u $expect $got; then
  echo "ok $step - $desc"
else
  echo "not ok $step - $desc"
  failed=$((failed+1))
fi
step=$((step+1))
echo

# Finish tests
count=$((step-1))
if [ $failed -ne 0 ]; then
  echo "Failed $failed/$count tests"
  exit 1
else
  echo "Passed $count tests"
fi
