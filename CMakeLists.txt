CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
## Now setting up project.
# A dummy target to add dependencies later.
project(moose-all)

set(MOOSE_PYTHON_DIRNAME moose-python)
set(MOOSE_GUI_DIRNAME moose-gui)
set(MOOSE_VERSION "3.0.2")

SET(MOOSE_PYTHON_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/moose-python)
SET(MOOSE_PYTHON_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/__moose_python)
FILE(MAKE_DIRECTORY ${MOOSE_PYTHON_BUILD_DIR})

## Options
option(PACKAGING_ON_LAUNCHPAD "Enable packaing on launchpad" OFF)
option(PACKAGING_ON_OBS "If we are packaging on OBS" OFF)


message(STATUS "CMAKE_INSTALL_PREFIX : ${CMAKE_INSTALL_PREFIX}")
add_custom_target(moose_all ALL)

# Add custom target
add_custom_command(
    OUTPUT ${MOOSE_PYTHON_BUILD_DIR}/moose.bin ${MOOSE_PYTHON_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    # Pass the environment variable so local installation gets searched.
    COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} 
        ${MOOSE_PYTHON_SOURCE_DIR}
    COMMAND $(MAKE)
    COMMAND $(MAKE) install
    WORKING_DIRECTORY ${MOOSE_PYTHON_BUILD_DIR}
    VERBATIM
    )


add_custom_target(_build_moose_python ALL
    DEPENDS ${MOOSE_PYTHON_BUILD_DIR}/moose.bin 
    ${MOOSE_PYTHON_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    )
add_dependencies(moose_all _build_moose_python)

## Following variable is used in configure file.
SET(MOOSEGUI_DIR /usr/lib/moose/gui)
CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/package_data/moosegui.in 
    ${CMAKE_INSTALL_PREFIX}/bin/moosegui
    )
# moose.bin script
SET(MOOSE_BIN_PATH /usr/bin)
CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/package_data/moose.in
    ${CMAKE_INSTALL_PREFIX}/bin/moose
    )

# Do not perform this step on launchpad or obs. 
IF(NOT PACKAGING_ON_OBS AND NOT PACKAGING_ON_LAUNCHPAD)
    MESSAGE(STATUS "Not building for Launchpad or OBS")
    install(CODE
        "
        EXECUTE_PROCESS(
            COMMAND python setup.py install --prefix=${CMAKE_INSTALL_PREFIX} 
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/moose-python/moose-core/python
            )
        "
        COMPONENT moose-gui
        )
ELSEIF(PACKAGING_ON_LAUNCHPAD)
    MESSAGE(STATUS "Packaging on Launchpad. Currently doing nothing")
ELSEIF(PACKAGING_ON_OBS)
    MESSAGE(STATUS "Packaging on OBS. Currently doing nothing.")
ENDIF()



#FILE(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/moose/gui)
set(MOOSE_GUI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/moose-gui)
install(DIRECTORY ${MOOSE_GUI_SOURCE_DIR}/moose-gui/
    DESTINATION lib/moose/gui
    COMPONENT moose-all
    )

# Keep the examples outside the gui directory
install(DIRECTORY ${MOOSE_GUI_SOURCE_DIR}/moose-examples/
    DESTINATION lib/moose/moose-examples
    COMPONENT moose-gui
    PATTERN "travis" EXCLUDE
    PATTERN "CVS" EXCLUDE
    PATTERN ".git*" EXCLUDE
    )

# install the launcher.

## DO NOT install icon and dekstop file. They cause a lot of issues on various
## repositories on open-build-service.

#### Install the icon
##install(FILES ${CMAKE_SOURCE_DIR}/moose-gui/icons/moose_icon.png 
##    DESTINATION share/pixmaps
##    COMPONENT moose-gui
##    RENAME moose.png
##    )
##
### And the desktop file.
##install(FILES ${CMAKE_SOURCE_DIR}/moose-core/scripts/moose.desktop
##    DESTINATION share/applications
##    COMPONENT moose-gui
##    )
##
### Tests.
enable_testing()
add_test(NAME moose-core 
    COMMAND ctest -R pymoose* --output-on-failure
    WORKING_DIRECTORY ${MOOSE_CORE_BUILD_DIR}
    )

