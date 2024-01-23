#!/usr/bin/env bash

# error in case of asdf install issues
set -e

# install (or update) asdf and plugins
if [[ -f "${HOME}/.asdf/asdf.sh" ]]; then
  source "${HOME}/.asdf/asdf.sh"
  asdf update
  asdf plugin update --all
else
  git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf" --branch v0.9.0
  source "${HOME}/.asdf/asdf.sh"
fi
echo 'legacy_version_file = yes' > ~/.asdfrc
asdf plugin list | grep -q terraform || asdf plugin add terraform
asdf plugin list | grep -q terraform-docs || asdf plugin add terraform-docs

# Don't fail immediately any more -- we'll depend on the final git status now
set +e

# run the test
./scripts/tf-gen.sh
generate_status=$?

echo
echo "=============================================="
echo "Terraform format and docs generation complete!"
echo "Results can be seen below. "
echo "=============================================="
echo

if [[ ${generate_status} == 0 ]]; then
  # generate succeeded, any changes?
  if git status | grep -q 'nothing to commit, working tree clean'; then
    echo "========================================================"
    echo "SUCCESS: Terraform is formatted and docs are up to date."
    echo "========================================================"
  else
    echo "===================================================================="
    echo "ERROR: Terraform files are not formatted or docs are not up to date!"
    echo "Below is the output of 'git status'. Any 'modified' files need to"
    echo "be updated. The simplest method to update them is to run the"
    echo "/scripts/tf-gen.sh script."
    echo "===================================================================="
    echo
    git status
    exit 1
  fi
else
  # generate failed
  echo "==================================================="
  echo "ERROR: Unknown error occurred while generating docs"
  echo "Build logs will need to be read to understand the"
  echo "error that occurred."
  echo "==================================================="
  echo
  git status
  exit 1
fi
