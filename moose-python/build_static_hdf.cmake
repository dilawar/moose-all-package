MESSAGE("++ Building local HDF5")

SET(HDF5_SRC_DIR ${CMAKE_SOURCE_DIR}/dependencies/hdf5-1.8.16)
SET(HDF5_INSTALL_DIR ${CMAKE_BINARY_DIR}/__hdf5_install)
FILE(MAKE_DIRECTORY ${HDF5_INSTALL_DIR})
MESSAGE("++ HDF5_SRC_DIR := ${HDF5_SRC_DIR}")

SET(HDF5_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/__hdf5_build__)
FILE(MAKE_DIRECTORY ${HDF5_BUILD_DIR})

SET(HDF5_OUTPUT_BIN 
    ${HDF5_INSTALL_DIR}/lib/libhdf5-static.a
    ${HDF5_INSTALL_DIR}/lib/libhdf5_hl-static.a
    )
ADD_CUSTOM_COMMAND(
    OUTPUT ${HDF5_OUTPUT_BIN}
    COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${HDF5_INSTALL_DIR} 
        -DBUILD_SHARED_LIBS=OFF -DHDF_EXTRA_C_FLAGS="-fPIC"
        ${HDF5_SRC_DIR}
    COMMAND $(MAKE) 
    COMMAND $(MAKE) install
    WORKING_DIRECTORY ${HDF5_BUILD_DIR}
    VERBATIM  # needed to handle escape characters.
    )

ADD_CUSTOM_TARGET(_libhdf5 ALL DEPENDS ${HDF5_OUTPUT_BIN})

set(HDF5_INCLUDE_DIR ${HDF5_INSTALL_DIR}/include)

## Ofcourse, moose-full depends on it.
add_dependencies(_moose_static_dependencies _libhdf5)
