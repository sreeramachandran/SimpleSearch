#!/bin/bash
if GIT_DIR=https://github.com/sreeramachandran/SimpleSearch/releases git rev-parse "$1^{1.7.0.2}" >/dev/null 2>&1
then
    echo "Found tag"
else
    echo "Tag not found"
fi