#!/bin/bash

rm -rf ./android/build &&

./android/prepare.sh &&

appc run -p android --project-dir android --build-only