# Builds

A build of builds using [pipeline-generator](https://github.com/soundcloud/pipeline-generator).

Add/Modify/Delete your build definitions to the `all-builds` directory and then run `build.sh`. It will connect to your configured jenkins server and do all required changes to your build pipelines.


## How To

### Add a Build

1. Create a file with the name of your project in `all-builds` with your pipeline-generator definition;
2. Run `build.sh`

### Update a Build

1. Modify your pipeline-generator definition on `all-builds`;
2. Run `build.sh`

### Remove a Build

1. Delete your pipeline-generator definition on `all-builds`;
2. Run `build.sh`


## Options

* **BUILDS_AUTO_COMMIT**: `true`/`false`, enables or disables  automatically commiting changes made to git after running `build.sh`. It defaults to `false`.
* **BUILDS_RUN_COMMAND**: path to command executed when changes are required to be done on jenkins. It defaults to `builds`.


## Build Build

```
» go get github.com/lucastorri/builds/
» cd $GOPATH/src/github.com/lucastorri/builds/
» go build
```


## Required Jenkins Plugins

* ansicolor
* build-pipeline-plugin
* copyartifact
* delivery-pipeline-plugin
* git
* jenkins-multijob-plugin
* next-build-number
* timestamper
