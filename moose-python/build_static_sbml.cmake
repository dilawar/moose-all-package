MESSAGE("+++ Building local sbml")
SET(SBML_INSTALL_DIR ${CMAKE_BINARY_DIR}/_libsbml_static)
FILE(MAKE_DIRECTORY ${SBML_INSTALL_DIR})

SET(SBML_SRC_DIR ${CMAKE_SOURCE_DIR}/dependencies/libsbml-5.9.0)
MESSAGE("++ SBML_SRC_DIR := ${SBML_SRC_DIR}")

# Use path, not string.
set(STATIC_SBML_LIBRARY ${SBML_INSTALL_DIR}/lib/libsbml-static.a)

# A target which depends on STATIC_SBML_LIBRARY
ADD_CUSTOM_COMMAND(
    OUTPUT ${STATIC_SBML_LIBRARY}
    COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${SBML_INSTALL_DIR}
        -DWITH_SWIG=OFF -DBUILD_SHARED_LIBS=OFF
        -DWITH_BZIP2=OFF -DWITH_ZLIB=OFF
    ${SBML_SRC_DIR}
    COMMAND $(MAKE)
    COMMAND $(MAKE) install
    WORKING_DIRECTORY ${SBML_INSTALL_DIR}
    VERBATIM
    )

ADD_CUSTOM_TARGET(_libsml ALL 
    DEPENDS ${STATIC_SBML_LIBRARY}
    )

set(ENV{LIBSBML_DIR} ${SBML_INSTALL_DIR})
# With option ALL it runs every time.
LIST(APPEND ALL_STATIC_LIBS ${STATIC_SBML_LIBRARY})
add_dependencies(_moose_static_dependencies _libsml)
