#!/bin/bash

TEST_BRANCH="test"


cd $(dirname "$0")
git checkout master

if [ `git branch --list "$TEST_BRANCH"` ]; then
  git branch -D "$TEST_BRANCH"
fi

git branch $TEST_BRANCH
git checkout $TEST_BRANCH

clean() {
	rm -f builds/{build-added,build-updated,build-same}
	rm -f .known-builds/{build-added,build-updated,build-same,build-removed} 
}

clean

touch builds/{build-added,build-updated,build-same}
touch .known-builds/{build-updated,build-same,build-removed} 

md5 -q builds/build-same > .known-builds/build-same

./build.sh

git checkout master
git branch -D "$TEST_BRANCH"
clean
