#!/bin/bash
echo "Updating moose-master branch in subtree"
(
git subtree push --prefix moose-core https://github.com/BhallaLab/moose-core master --squash
)
