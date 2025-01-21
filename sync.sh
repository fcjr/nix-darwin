#!/bin/bash

set -e # exit on error
set -x # echo on

git fetch upstream master
git rebase upstream/master
git push -f