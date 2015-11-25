CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(moose-gui)

FIND_PACKAGE(PythonInterp REQUIRED)

# Target does not build anything.
add_custom_target(moosegui ALL)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/moose-gui/
    DESTINATION lib/moose/gui
    COMPONENT moose-gui
    )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/moose-examples
    DESTINATION lib/moose/
    COMPONENT moose-gui
    PATTERN "_travis" EXCLUDE
    PATTERN "CVS" EXCLUDE
    PATTERN ".git*" EXCLUDE
    )

# create the launcher.
SET(MOOSEGUI_DIR /usr/lib/moose/gui)
CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/scripts/moosegui.in 
    ${CMAKE_CURRENT_BINARY_DIR}/moosegui
    )

# install the launchers,
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/moosegui
    DESTINATION bin
    COMPONENT moose-all
    )


## TODO: Need to add some tests here.
