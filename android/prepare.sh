#!/usr/bin/env bash

#
# Expands contents of .aar file into 
#

ANDROID_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

AAR_PATH="$ANDROID_DIR/zoom-authentication.aar"

LIB_DIR="$ANDROID_DIR/lib"
ASSETS_DIR="$ANDROID_DIR/assets"

rm -rf $LIB_DIR/* &&
rm -rf $ASSETS_DIR* &&
rm -rf $ANDROID_DIR/libs/ &&
rm -rf $ANDROID_DIR/platform/android/res/* &&

# Dependency libs (not necessary if proguarded)
unzip -jo $AAR_PATH libs/*.jar -d $LIB_DIR/ &

# Main lib
unzip -jo $AAR_PATH classes.jar -d $LIB_DIR/ &&
mv $LIB_DIR/classes.jar $LIB_DIR/zoom-authentication.jar &&

# armeabi-v7a native libs
mkdir -p $ANDROID_DIR/libs/ &&
unzip -o $AAR_PATH jni/* -d $ANDROID_DIR/libs/ &&
mv $ANDROID_DIR/libs/jni/* $ANDROID_DIR/libs/ &&
rm -rf $ANDROID_DIR/libs/jni

# Assets
unzip -o $AAR_PATH assets/* -d $ASSETS_DIR/ &&
mv $ANDROID_DIR/assets/assets/* $ANDROID_DIR/assets/ &&
rm -rf $ANDROID_DIR/assets/assets

# Resources
unzip -o $AAR_PATH res/* -d $ANDROID_DIR/platform/android
