#!/bin/bash
echo "Updating moose-master branch in subtree"
(
git subtree push --prefix moose-gui https://github.com/BhallaLab/moose-gui master --squash
git subtree push --prefix moose-examples https://github.com/BhallaLab/moose-examples master --squash
)
