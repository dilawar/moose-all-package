#!/bin/bash
echo "Updating moose branches in subtree"
(
git subtree pull --prefix moose-core https://github.com/BhallaLab/moose-core master --squash
)
