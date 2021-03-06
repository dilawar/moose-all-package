#!/bin/bash
set -x
set -e

rm -f /Library/Caches/Homebrew/moose*.tar.gz
rm -f /Library/Caches/Homebrew/moose*.zip

cp ./moose.rb /usr/local/Library/Formula/moose.rb

brew -v install moose --with-gui --with-sbml | tee _build_moose.log 

echo "Checking brew script for submission"
brew audit --strict moose
brew -v test moose
