# Packaging.
INCLUDE(InstallRequiredSystemLibraries)
SET(CPACK_SOURCE_STRIP_FILES ON)
SET(CPACK_SOURCE_IGNORE_FILES "${CPACK_SOURCE_IGNORE_FILES};*_build*")
SET(CPACK_GENERATOR "DEB;RPM;STGZ;TGZ;TZ")
SET(CPACK_PACKAGE_NAME "moose-all")
SET(CPACK_PACKAGE_VENDOR "Bhalla Lab, NCBS Bangalore")
SET(CPACK_PACKAGE_VERSION "3.0.2")
SET(CPACK_PACKAGE_VERSION_MAJOR "3")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "2")
SET(CPACK_SOURCE_GENERATOR "TGZ;TZ")
SET(CPACK_PACKAGE_CONTACT "Dilawar Singh <dilawars@ncbs.res.in>")
include(CPack)