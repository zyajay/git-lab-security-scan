#!/bin/sh

# Make it TAP compliant, see http://testanything.org/tap-specification.html
echo "1..2"

failed=0
step=1

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

# Finish tests
count=$((step-1))
if [ $failed -ne 0 ]; then
  echo "Failed $failed/$count tests"
  exit 1
else
  echo "Passed $count tests"
fi
