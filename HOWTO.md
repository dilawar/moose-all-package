This document describes the pipeline for packing MOOSE using OpenBuildService/Launchpad. And how to build a standalone dmg file for macosx.

# Whole pipeline 

## moose-python

    $ git clone https://github.com/BhallaLab/moose-python-package
    $ cd moose-python-package 

Now, pull the changes from development repositories.

    $ ./scripts/pull_moose_branch.sh
    $ git commit -u :/ 
    $ git push 

Also push changaes to launchpad-mirror [lp:moose-python](https://code.launchpad.net/~bhallalab/moose-python/master). 
    
    $ git remote add launchpad git://git.launchpad.net/moose-python 
    $ git push launchpad master

This should trigger the build of moose-python package on launchad.

## moose-gui

Almost similar.

    $ git clone https://github.com/BhallaLab/moose-gui-package
    $ cd moose-gui-package 

Now, pull the changes from development repositories.

    $ ./scripts/pull_moose_branch.sh
    $ git commit -u :/ 
    $ git push 

Also push changaes to launchpad-mirror [lp:moose-gui](https://code.launchpad.net/~bhallalab/moose-gui/master). 
    
    $ git remote add launchpad git://git.launchpad.net/moose-gui 
    $ git push launchpad master

This should trigger the build of moose-gui package on launchad.

## moose-all

This package is sum of moose-python and moose-gui. We use https://github.com/BhallaLab/moose-all-package  repository for this. This repo keeps https://github.com/BhallaLab/moose-python-package and https://github.com/BhallaLab/moose-gui-package repositories as subtree. Unless these two repositories are updated, nothing new will appear in this repo. 

    $ git clone https://github.com/BhallaLab/moose-all-package
    $ cd moose-all-package 

Now, pull the changes from development repositories.

    $ ./scripts/pull_moose_branch.sh
    $ git commit -u :/ 
    $ git push 

Also push changaes to launchpad-mirror [lp:moose](https://code.launchpad.net/~bhallalab/moose/master). 
    
    $ git remote add launchpad git://git.launchpad.net/moose
    $ git push launchpad master

This should trigger the build process of moose package on launchad.

# Open Build Service

Once the github repositories are updated, wait for openbuildservice to build the
new package. The project page is here https://build.opensuse.org/package/show/home:moose/moose
and  https://build.opensuse.org/package/show/home:moose/moogli.


# Notes

## moose-python (https://github.com/BhallaLab/moose-python-pack)

It keeps [moose-core](https://github.com/BhallaLab/moose-core) and other
dependencies (hdf5, sbml, and gsl2) in one place. CMakeLists.txt is modified to
build for DEB/RPM package. The development repository
[moose-core](https://github.com/BhallaLab/moose-core) is integrated as
git-subtree. To bring any changes from moose-core into package, run
`./scripts/pull_moose_branch.sh' script. To push changes from here to
moose-core, one can use `./scripts/push_moose_branch.sh`.

Folder `debian` is added for launchpad. This repo is used to build
`moose-python` package on launchpad.

## moose-gui  (https://github.com/BhallaLab/moose-gui-all)

This keeps [moose-gui](https://github.com/BhallaLab/moose-gui) and
[moose-examples](https://github.com/BhallaLab/moose-examples) repository.

Folder `debian` keeps the required debian files. This repo is added to launchpad
to build `moose-gui` package.

# On MacOSX

Just run the script `./macosx/build_dmg_image_using_brew.sh` which should create a dmg file with MOOSE installed in it. After that to cleanup the installation, run `./macosx/release_dmg_file.sh`. Then, compress the dmg for distribution. 
