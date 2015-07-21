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
	rm -f all-builds/{build-added,build-updated,build-same}
	rm -f .known-builds/{build-added,build-updated,build-same,build-removed} 
}

setup() {
	clean
	touch all-builds/{build-added,build-updated,build-same}
	touch .known-builds/{build-updated,build-same,build-removed} 
	echo a > all-builds/build-updated
}

teardown() {
	git checkout master
	git branch -D "$TEST_BRANCH"
	clean
}


setup
./build.sh
teardown

