#!/bin/bash
set -e
message=$1
jekyll build
cd ./_site

git add ./
git commit -m "$message"
git push origin gh-pages
