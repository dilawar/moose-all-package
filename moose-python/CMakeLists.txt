CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
## Now setting up project.
# A dummy target to add dependencies later.
project(moose-all)

add_custom_target(_moose_static_dependencies ALL)
# This variable should point to the source code.
set(MOOSE_CORE_DIRNAME moose-core)
set(MOOSE_VERSION "3.0.2")

## CMAKE options
option(WITH_DOC "Build documentation as well" OFF)

## Project related macros
set(MOOSE_SOURCE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${MOOSE_CORE_DIRNAME})

set(CMAKE_MODULE_PATH "${MOOSE_SOURCE_DIRECTORY}/cmake_modules")
message(STATUS "CMAKE_MODULE_PATH := ${CMAKE_MODULE_PATH}")

# This is a modification for packaging purpose only. This script should never be
# used for any other purpose.

##############
# Architecture.
MESSAGE("++ Testing for architecture: 64 bit or 32 bit")
if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
    MESSAGE("++ 64 bit architecture")
    set(LIBSUFFIX "64")
    set(PKGARCH "amd64")
    set(RPMPKGARCH "x86_64")
else()
    MESSAGE("++ 32 bit architecture")
    set(LIBSUFFIX "")
    set(PKGARCH "i386")
endif()

################
# Definately building release type ##########################
set(CMAKE_BUILD_TYPE Release)
# This is essential to remove the RPATH.
set(CMAKE_INSTALL_RPATH "")

################
# Which local libraries need to be built, Here we just set the
# the flags.
find_package(GSL 1.16)
# If installed version of gsl is not 1.16 then download and build gsl locally.
# THIS IS USEFULL TO BUILD MOOSE FOR VARIOUS DISTRIBUTIONS.
if(NOT GSL_FOUND)
    MESSAGE("++ No GSL found. Using local gsl")
    set(LOCAL_GSL 1)
else()
    message("++ GSL_VERSION ${GSL_VERSION}")
    if(${GSL_VERSION} VERSION_LESS 1.16)
        MESSAGE("++ Trouble. Needed version 1.16. I'll now build GSL locally and
        link it with MOOSE")
        SET(LOCAL_GSL 1)
    endif()
endif()

set(ALL_STATIC_LIBS "")
if(LOCAL_GSL)
    include(${CMAKE_CURRENT_SOURCE_DIR}/build_static_gsl.cmake)
endif()

## SBML
find_package(LIBSBML)
if(NOT LIBSBML_FOUND)
    MESSAGE(STATUS "++ LIBSBML NOT FOUND. Building local SBML")
    include(${CMAKE_CURRENT_SOURCE_DIR}/build_static_sbml.cmake)
endif() 

find_package(HDF5)
IF(NOT FOUND_HDF5)
    MESSAGE("++ HDF5 not found. Building static hdf5")
    include(${CMAKE_CURRENT_SOURCE_DIR}/build_static_hdf.cmake)
    SET(HDF5_STATIC_HOME ${HDF5_INSTALL_DIR})
ENDIF(NOT FOUND_HDF5)

## Now build MOOSE
SET(MOOSE_CORE_BUILD_DIR ${CMAKE_BINARY_DIR}/_moose-core)
FILE(MAKE_DIRECTORY ${MOOSE_CORE_BUILD_DIR})
## Dont use external project. The environment variables are lost.
message(STATUS "CMAKE_INSTALL_PREFIX : ${CMAKE_INSTALL_PREFIX}")
add_custom_command(
    OUTPUT ${MOOSE_CORE_BUILD_DIR}/moose.bin ${MOOSE_CORE_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    # Pass the environment variable so local installation gets searched.
    COMMAND GSL_HOME=${GSL_INSTALL_DIR} LIBSBML_DIR=${SBML_INSTALL_DIR}
    ${CMAKE_COMMAND} 
        -DDEBUG:BOOL=OFF 
        -DWITH_DOC:BOOL=${WITH_DOC}
        -DGSL_STATIC_HOME=${GSL_INSTALL_DIR}
        -DSBML_STATIC_HOME=${SBML_INSTALL_DIR}
        -DHDF5_STATIC_HOME=${HDF5_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_SKIP_RPATH=ON
        ${MOOSE_SOURCE_DIRECTORY}
    COMMAND $(MAKE) VERBOSE=1
    # Not running neuroml test since it requires matplotlib.
    #COMMAND ctest -E neuroml --output-on-failure
    # Build and test, do not install here.
    WORKING_DIRECTORY ${MOOSE_CORE_BUILD_DIR}
    VERBATIM
    )

add_custom_target(_build_moose_core ALL
    DEPENDS ${MOOSE_CORE_BUILD_DIR}/moose.bin 
    ${MOOSE_CORE_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    )

add_dependencies(_build_moose_core _moose_static_dependencies)

# moose script
# Use moose-core cmake file to install its targets.
IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
    MESSAGE(AUTHOR_WARNING "moose-core installation is for debugging purpose.")
    MESSAGE(STATUS "Installing core component because of debug mode")
    SET(MOOSE_BIN_PATH /usr/bin)
    CONFIGURE_FILE(
        ${CMAKE_CURRENT_SOURCE_DIR}/scripts/moose.in
        ${CMAKE_CURRENT_BINARY_DIR}/moose
        )
    install(CODE 
        "
        EXECUTE_PROCESS(
            COMMAND ${CMAKE_COMMAND} -P ${MOOSE_CORE_BUILD_DIR}/cmake_install.cmake
        )"
       COMPONENT moose-core
     )
    install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/moose
     DESTINATION bin
     COMPONENT moose-core
     )

ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)

# This step will differ on launchpad or obs
SET(PYMOOSE_INSTALL_ARGS --prefix ${CMAKE_INSTALL_PREFIX})
IF(NOT PACKAGING_ON_OBS AND NOT PACKAGING_ON_LAUNCHPAD)
    MESSAGE(STATUS "Not building for Launchpad or OBS")
    SET(PYMOOSE_INSTALL_ARGS --prefix ${CMAKE_INSTALL_PREFIX})
ELSEIF(PACKAGING_ON_LAUNCHPAD)
    MESSAGE(STATUS "Packaging on Launchpad. Currently doing nothing")
    SET(PYMOOSE_INSTALL_ARGS --root=${CMAKE_INSTALL_PREFIX} --install-layout=deb)
ELSEIF(PACKAGING_ON_OBS)
    MESSAGE(STATUS "Packaging on OBS. Currently doing nothing.")
    SET(PYMOOSE_INSTALL_ARGS --prefix=${CMAKE_INSTALL_PREFIX}) 
ENDIF()

install(CODE
    "
    EXECUTE_PROCESS(
        COMMAND python setup.py install ${PYMOOSE_INSTALL_ARGS}
        WORKING_DIRECTORY ${MOOSE_CORE_BUILD_DIR}/python
        )
    "
    COMPONENT moose-python
    )

### Tests.
enable_testing()
add_test(NAME moose-core 
    COMMAND ctest -R pymoose* --output-on-failure
    WORKING_DIRECTORY ${MOOSE_CORE_BUILD_DIR}
    )

