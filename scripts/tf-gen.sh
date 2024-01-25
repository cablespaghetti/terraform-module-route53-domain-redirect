#!/usr/bin/env bash

# track the number of errors that occur...
NUM_ERRORS=0
function track-errors() {
  # shellcheck disable=SC2181
  if [[ $? -gt 0 ]]; then
    ((NUM_ERRORS+=1))
    echo "ERROR: Unknown error occurred. See above for the full error output."
    return 1
  fi
}

function tfgen() {
  local desired_tf_ver
  desired_tf_ver=$(asdf current terraform 2>&1 | awk '{print $2}')
  echo "Installing Terraform (${desired_tf_ver})..."
  if [[ $(uname) == Darwin && $(uname -m) == arm64 ]]; then
    if verlte "1.0.1" ${desired_tf_ver}; then
      echo "M1 Mac support: Forcing installation of amd64 binary for older Terraform version."
      export ASDF_HASHICORP_OVERWRITE_ARCH="amd64"
    fi
  fi
  asdf install terraform
  track-errors || return

  echo "Formatting..."
  terraform fmt .
  track-errors || return

  if [[ -f docs-header.md ]]; then
    echo "Generating docs..."
    terraform-docs -c "${TFDOCS_CONFIG_FILE}" . > README.md
    track-errors
  else
    echo "Skip generating docs: no 'docs-header.md' found."
  fi
}

# stolen from https://github.com/rbenv/ruby-build/pull/631/files#diff-fdcfb8a18714b33b07529b7d02b54f1dR942
function sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' | \
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

function verlte() {
  # Used in the official asdf-nodejs plugin.
  #   https://github.com/asdf-vm/asdf-nodejs/blob/c0f37e2d14c630b04bace43c79bb361334723216/bin/install#L313-L316
  # See also:
  #   https://stackoverflow.com/questions/4023830/how-compare-two-strings-in-dot-separated-version-format-in-bash/4024263#4024263
  # Note however, that we look at the _tail_ of the list rather than the head because our sort is backwards
  [  "$1" = "$(echo -e "$1\n$2" | sort_versions | tail -n1)" ]
}

##
# Main
##

START_DIR=$(pwd)
BASE_DIR="$(git rev-parse --show-toplevel)"

echo "Installing Terraform Docs..."
asdf install terraform-docs || { echo "ERROR: installing terraform-docs failed."; exit 1; }

TFDOCS_CONFIG_FILE="${BASE_DIR}/.terraform-docs.yml"

if [[ $# == 0 ]]; then
  dir=$1
  if [[ ${dir} == "." || ${dir} == "./" ]]; then
    dir=${START_DIR}
  fi
  # shellcheck disable=SC2164
  cd "${dir}"
  tfgen
fi

# exit code indicates error count
exit "${NUM_ERRORS}"
