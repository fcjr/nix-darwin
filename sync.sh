#!/bin/bash

set -e # exit on error
set -x # echo on

git fetch upstream nix-darwin-24.11
git rebase upstream/nix-darwin-24.11
git push -f