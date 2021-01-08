#!/bin/sh

set -e

TARGET="$HOME/bin"
if [ $(id -u) -eq 0 ]; then
    TARGET="/usr/local/bin"
fi
echo "Installing dev tools to $TARGET"

mkdir -p $TARGET
curl --silent --location \
       https://raw.githubusercontent.com/houseabsolute/ubi/master/bootstrap/bootstrap-ubi.sh |
       sh

"$TARGET/ubi" --project houseabsolute/precious --in "$TARGET"
"$TARGET/ubi" --project houseabsolute/omegasort --in "$TARGET"

echo "Add $TARGET to your PATH in order to use precious for linting and tidying"
