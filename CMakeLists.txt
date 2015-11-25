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

## Tests.
enable_testing()
add_test(NAME moose-core 
    COMMAND ctest -R pymoose* --output-on-failure
    WORKING_DIRECTORY ${MOOSE_CORE_BUILD_DIR}
    )

