CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
## Now setting up project.
# A dummy target to add dependencies later.
project(moose-all)
set(MOOSE_VERSION "3.0.2")

SET(MOOSE_PYTHON_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/moose-python)
SET(MOOSE_PYTHON_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/__moose_python)
FILE(MAKE_DIRECTORY ${MOOSE_PYTHON_BUILD_DIR})

## Options
option(PACKAGING_ON_LAUNCHPAD "Enable packaing on launchpad" OFF)
option(PACKAGING_ON_OBS "If we are packaging on OBS" OFF)


message(STATUS "CMAKE_INSTALL_PREFIX : ${CMAKE_INSTALL_PREFIX}")
add_custom_target(moose_all ALL)

# NOTE: Make sure to install moose-python and moose-gui to differnt prefixes.
# Otherwise each call of make install with overwrite.
SET(MOOSE_PYTHON_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/_moose_python_)
add_custom_command(
    OUTPUT ${MOOSE_PYTHON_BUILD_DIR}/moose.bin ${MOOSE_PYTHON_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    # Pass the environment variable so local installation gets searched.
    COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${MOOSE_PYTHON_INSTALL_DIR}
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

# build moose-gui.
set(MOOSE_GUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/moose-gui)
set(MOOSE_GUI_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/_moose_gui_)
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/moosegui
    COMMAND ${CMAKE_COMMAND} 
        -DCMAKE_INSTALL_PREFIX=${MOOSE_GUI_INSTALL_DIR}
        ${MOOSE_GUI_DIR}
    COMMAND $(MAKE)
    COMMAND $(MAKE) install
    WORKING_DIRECTORY ${MOOSE_GUI_DIR}
    VERBATIM
    )
add_custom_target(_build_moose_gui ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/moosegui
    )
add_dependencies(moose_all _build_moose_gui)

# Build moogli
set(MOOGLI_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/moogli)
set(MOOGLI_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/_moogli)
SET(MOOGLI_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/_moogli_build)
FILE(MAKE_DIRECTORY ${MOOGLI_BIN_DIR})
add_custom_command(
    OUTPUT ${MOOGLI_SRC_DIR}/moogli/core/_moogli.so
    COMMAND ${CMAKE_COMMAND} 
        -DCMAKE_INSTALL_PREFIX=${MOOGLI_INSTALL_DIR} ${MOOGLI_SRC_DIR}
    COMMAND $(MAKE)
    COMMAND $(MAKE) install
    WORKING_DIRECTORY ${MOOGLI_BIN_DIR}
    VERBATIM
    )
add_custom_target(_build_moogli ALL
    DEPENDS ${MOOGLI_SRC_DIR}/moogli/core/_moogli.so
    )
add_dependencies(moose_all _build_moogli)

# Leading character is very important.
INSTALL(DIRECTORY ${MOOSE_GUI_INSTALL_DIR}/
    DESTINATION usr
    USE_SOURCE_PERMISSIONS
    )

INSTALL(DIRECTORY ${MOOSE_PYTHON_INSTALL_DIR}/
    DESTINATION usr
    USE_SOURCE_PERMISSIONS
    )

INSTALL(DIRECTORY ${MOOGLI_INSTALL_DIR}
    DESTINATION usr
    USE_SOURCE_PERMISSIONS
    )

## Tests.
enable_testing()
add_test(NAME moose-core 
    COMMAND ctest -R pymoose* --output-on-failure
    WORKING_DIRECTORY ${MOOSE_CORE_BUILD_DIR}
    )

