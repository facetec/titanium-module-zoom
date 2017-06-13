#!/bin/bash

rm -rf ./android/build &&

./android/prepare.sh &&

ti build --platform android --project-dir android --build-only