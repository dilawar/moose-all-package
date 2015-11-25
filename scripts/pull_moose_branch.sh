#!/bin/bash

# NOTE: notice that we are using moose-python-package etc repositories.
echo "Updating moose branches in subtree"
(
git subtree pull --prefix moose-python https://github.com/BhallaLab/moose-python-package master --squash
git subtree pull --prefix moose-gui https://github.com/BhallaLab/moose-gui-package master --squash
)
