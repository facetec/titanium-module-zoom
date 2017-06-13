#!/bin/bash

MANIFEST_VERSION=$(cat iphone/manifest | grep '^version: [^s]' | grep -Eo '[0-9\.]{1,}')

if [ ! $MANIFEST_VERSION ]; then
    echo 'Manifest version not found'
    exit 1
fi

sed "s/##VERSION##/$MANIFEST_VERSION/g" iphone/module.xcconfig.base > iphone/module.xcconfig &&

rm -rf iphone/build/* &&
rm -rf iphone/com.facetec*.zip &&

ti build --platform iphone --project-dir iphone --build-only