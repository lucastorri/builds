
test_branch="test"

git checkout master

if [ `git branch --list $test_branch `]; then
  git branch -D $test_branch
fi

git branch $test_branch
git checkout $test_branch

rm -f builds/*
rm -f .known-builds/*

touch builds/{build-added,build-updated,build-same}
touch .known-builds/{build-updated,build-same,build-removed} 

md5 -q builds/build-same > .known-builds/build-same
