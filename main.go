package main

import (
	pipeline "github.com/soundcloud/pipeline-generator"
	"os"
	"fmt"
	"path/filepath"
)

func failOnError(err error) {
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
}

func file() (f *os.File, err error) {
	if path, err := filepath.Abs(os.Args[2]); err == nil {
		f, err = os.Open(path)
	}
	return
}

func usage(err error) {
	fmt.Println("USAGE: pipeline {create|delete|update} <pipeline-file>")
	failOnError(err)
}

func main() {
	if len(os.Args) != 3 {
		usage(fmt.Errorf("Wrong number of arguments"))
	}

	f, err := file()
	failOnError(err)
	defer f.Close()

	pipeline, err := pipeline.NewJenkinsPipeline(f)
	failOnError(err)

	jenkins := pipeline.JenkinsServer
	name, err := pipeline.DefaultName()
	failOnError(err)

	switch os.Args[1] {
	case "delete":
		_, err := jenkins.DeletePipeline(name)
		failOnError(err)
	case "update":
		var url string
		url, err := pipeline.UpdatePipeline(name)
		failOnError(err)
		fmt.Println(url)
	case "create":
		url, err := pipeline.CreatePipeline(name)
		failOnError(err)
		fmt.Println(url)
	default:
		usage(fmt.Errorf("Unkown command %s", os.Args[0]))
	}
}
