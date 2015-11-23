#!/bin/bash
echo "Adding master branch in subtree"
(
    git subtree add  --prefix moose-core https://github.com/BhallaLab/moose-core master --squash
)
