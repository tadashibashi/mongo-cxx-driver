# Copyright 2016 MongoDB Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/version.hpp.in
    ${CMAKE_CURRENT_BINARY_DIR}/version.hpp
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/config.hpp.in
    ${CMAKE_CURRENT_BINARY_DIR}/config.hpp
)

if (DEFINED CMAKE_CXX_COMPILER_ID)
    set (MONGOCXX_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}")
else ()
    set (MONGOCXX_COMPILER_ID "Unknown")
endif ()

if (DEFINED CMAKE_CXX_COMPILER_VERSION)
    set (MONGOCXX_COMPILER_VERSION "${CMAKE_CXX_COMPILER_VERSION}")
else ()
    set (MONGOCXX_COMPILER_VERSION "Unknown")
endif ()

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/private/config.hh.in
    ${CMAKE_CURRENT_BINARY_DIR}/private/config.hh
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/config.hpp
    ${CMAKE_CURRENT_BINARY_DIR}/version.hpp
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mongocxx/v_noabi/mongocxx/config
    COMPONENT dev
)

set_dist_list (src_mongocxx_config_DIST
   CMakeLists.txt
   config.hpp.in
   private/config.hh.in
   private/postlude.hh
   private/prelude.hh
   version.hpp.in
)
