#!/bin/bash

TEST_BRANCH="test"


cd $(dirname "$0")
git checkout master

if [ `git branch --list "$TEST_BRANCH"` ]; then
  git branch -D "$TEST_BRANCH"
fi

git branch $TEST_BRANCH
git checkout $TEST_BRANCH

rm -f builds/*
rm -f .known-builds/*

touch builds/{build-added,build-updated,build-same}
touch .known-builds/{build-updated,build-same,build-removed} 

md5 -q builds/build-same > .known-builds/build-same

./build.sh
