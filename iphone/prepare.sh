#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf $SCRIPT_DIR/Resources/ZoomAuthentication.framework &&

unzip ZoomAuthentication.framework.zip -d ./Resources/