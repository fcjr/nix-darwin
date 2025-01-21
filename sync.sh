#!/bin/bash

set -e # exit on error
set -x # echo on

git fetch upstream nix-darwin-25.05
git rebase upstream/nix-darwin-25.05
git push -f