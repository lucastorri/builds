#!/bin/bash

source "$(dirname "$0")/lib.sh"


git_repo=`git config --get remote.origin.url`

run create <(cat << EOM
{
    "stages": [
        {
            "name": "builds",
            "jobs": [
                { "builds": "./build.sh" }
            ]
        }
    ],
    "settings": {
        "jenkins-server": "$build_server",
        "default-name": "builds",
        "git-url": "$git_repo",
        "job-setup": "export BUILDS_AUTO_COMMIT=true"
    }
}
EOM)
