#!/bin/sh

TAG=fuzz-nebula
ROOT=fuzz/root

docker build -t $TAG -f fuzz/Dockerfile .
mkdir -p $ROOT
docker run --privileged \
       -v $(realpath $ROOT):/out \
       -v $(realpath fuzz):/work \
       -e FUZZING_ENGINE=libfuzzer \
       -e FUZZING_LANGUAGE=go \
       -e SANITIZER=address \
       -e ARCHITECTURE=x86_64 \
       -e PROJECT_NAME=nebula \
       $TAG
