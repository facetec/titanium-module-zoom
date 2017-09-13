#!/bin/bash

rm -rf iphone/build/* &&
rm -rf iphone/com.facetec*.zip &&

appc run -p ios --project-dir iphone --build-only
