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

message(STATUS "CMAKE_INSTALL_PREFIX : ${CMAKE_INSTALL_PREFIX}")
add_custom_target(moose_all ALL)

# Add custom target
add_custom_command(
    OUTPUT ${MOOSE_PYTHON_BUILD_DIR}/moose.bin ${MOOSE_PYTHON_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    # Pass the environment variable so local installation gets searched.
    COMMAND ${CMAKE_COMMAND} ${MOOSE_PYTHON_SOURCE_DIR}
    WORKING_DIRECTORY ${MOOSE_PYTHON_BUILD_DIR}
    VERBATIM
    )

add_custom_target(_build_moose_python ALL
    DEPENDS ${MOOSE_PYTHON_BUILD_DIR}/moose.bin 
    ${MOOSE_PYTHON_BUILD_DIR}/moose-${MOOSE_VERSION}.tar.gz
    )

add_dependencies(moose_all _build_moose_python)

# Use moose-core cmake file to install its targets.
install(CODE 
    "
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} -P ${MOOSE_PYTHON_BUILD_DIR}/cmake_install.cmake
        )"
    COMPONENT moose-all
    )

install(CODE
    "
    EXECUTE_PROCESS(
        COMMAND python setup.py install --prefix=${CMAKE_INSTALL_PREFIX} 
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/moose-python/moose-core/python
        )
    "
    COMPONENT moose-gui
    )


SET(MOOSE_GUI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/moose-gui)
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

