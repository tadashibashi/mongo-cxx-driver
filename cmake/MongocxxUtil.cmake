# Define and link a form of the mongocxx library
#
# This function requires the following variables to be defined in its parent scope:
# - mongocxx_sources
# - libmongoc_target
# - libmongoc_definitions
# - libmongoc_definitions
function(mongocxx_add_library TARGET OUTPUT_NAME LINK_TYPE)
    add_library(${TARGET} ${LINK_TYPE}
        ${mongocxx_sources}
    )

    set_target_properties (${TARGET} PROPERTIES
        OUTPUT_NAME ${OUTPUT_NAME}
        VERSION ${MONGOCXX_VERSION}
        DEFINE_SYMBOL MONGOCXX_EXPORTS
    )

    if(LINK_TYPE STREQUAL "SHARED")
        set_target_properties (${TARGET} PROPERTIES
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN ON
            SOVERSION _noabi
        )
    endif()

    if(LINK_TYPE STREQUAL "STATIC")
        target_compile_definitions(${TARGET} PUBLIC MONGOCXX_STATIC)
    endif()

    target_link_libraries(${TARGET} PRIVATE ${libmongoc_target})
    target_include_directories(${TARGET} PRIVATE ${libmongoc_include_directories})
    target_include_directories(
        ${TARGET}
        PUBLIC
            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include/mongocxx/v_noabi>
            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/lib/mongocxx/v_noabi>
            $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/lib/mongocxx/v_noabi>
    )
    target_compile_definitions(${TARGET} PRIVATE ${libmongoc_definitions})

    generate_export_header(${TARGET}
        BASE_NAME MONGOCXX
        EXPORT_MACRO_NAME MONGOCXX_API
        NO_EXPORT_MACRO_NAME MONGOCXX_PRIVATE
        EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/lib/mongocxx/v_noabi/mongocxx/config/export.hpp
        STATIC_DEFINE MONGOCXX_STATIC
    )
endfunction(mongocxx_add_library)

# Install the specified forms of the mongocxx library (i.e., shared and/or static)
# with associated CMake config files
function(mongocxx_install MONGOCXX_TARGET_LIST MONGOCXX_PKG_DEP)
    install(TARGETS
            ${MONGOCXX_TARGET_LIST}
        EXPORT mongocxx_targets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT runtime
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT runtime
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT dev
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mongocxx/v_noabi
    )

    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/mongocxx-config-version.cmake"
        VERSION ${MONGOCXX_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    configure_file(cmake/mongocxx-config.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/mongocxx-config.cmake"
        @ONLY
    )

    install(EXPORT mongocxx_targets
        NAMESPACE mongo::
        FILE mongocxx_targets.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mongocxx-${MONGOCXX_VERSION}
    )

    install(
        FILES
            "${CMAKE_CURRENT_BINARY_DIR}/mongocxx-config-version.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/mongocxx-config.cmake"
        DESTINATION
            ${CMAKE_INSTALL_LIBDIR}/cmake/mongocxx-${MONGOCXX_VERSION}
        COMPONENT
            Devel
    )
endfunction(mongocxx_install)

function(mongocxx_install_deprecated_cmake NAME)
    set(PKG "lib${NAME}")

    configure_package_config_file(
      cmake/${PKG}-config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/${PKG}-config.cmake
      INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PKG}-${MONGOCXX_VERSION}
      PATH_VARS PACKAGE_INCLUDE_INSTALL_DIRS PACKAGE_LIBRARY_INSTALL_DIRS
    )

    write_basic_package_version_file(
      ${CMAKE_CURRENT_BINARY_DIR}/${PKG}-config-version.cmake
      VERSION ${MONGOCXX_VERSION}
      COMPATIBILITY SameMajorVersion
    )

    install(
      FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG}-config.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKG}-config-version.cmake
      DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PKG}-${MONGOCXX_VERSION}
    )
endfunction(mongocxx_install_deprecated_cmake)
