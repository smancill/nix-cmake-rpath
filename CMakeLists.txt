cmake_minimum_required(VERSION 3.11)
project(NixCMakeRPATH LANGUAGES CXX)

option(DEFINE_INSTALL_RPATH "Set the install RPATH" ON)
option(BUILD_TESTING "Build tests" ON)

set(BUILD_SHARED_LIBS ON)

include(GNUInstallDirs)

message("CMAKE_INSTALL_BINDIR: ${CMAKE_INSTALL_BINDIR}")
message("CMAKE_INSTALL_LIBDIR: ${CMAKE_INSTALL_LIBDIR}")

if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}/bin)
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif()
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_compile_options(-Wall -Wextra)

if(DEFINE_INSTALL_RPATH)
  if(APPLE)
    set(basePoint @loader_path)
  else()
    set(basePoint $ORIGIN)
  endif()
  file(RELATIVE_PATH relDir ${CMAKE_INSTALL_FULL_BINDIR} ${CMAKE_INSTALL_FULL_LIBDIR})
  set(CMAKE_INSTALL_RPATH ${basePoint} ${basePoint}/${relDir})
endif()
message("CMAKE_INSTALL_RPATH: ${CMAKE_INSTALL_RPATH}")
message("CMAKE_SKIP_BUILD_RPATH: ${CMAKE_SKIP_BUILD_RPATH}")
message("CMAKE_SKIP_INSTALL_RPATH: ${CMAKE_SKIP_INSTALL_RPATH}")
message("CMAKE_SKIP_RPATH: ${CMAKE_SKIP_RPATH}")


find_package(jsoncpp REQUIRED)

add_library(hello_lib src/hello_lib.cpp)
set_target_properties(hello_lib PROPERTIES OUTPUT_NAME hello)
target_link_libraries(hello_lib PRIVATE jsoncpp_lib)
target_include_directories(hello_lib PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>)

install(TARGETS hello_lib
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

add_executable(hello src/hello.cpp)
target_link_libraries(hello hello_lib)

install(TARGETS hello
  DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(BUILD_TESTING)
  enable_testing()
  add_executable(test_hello_lib test/test_hello_lib.cpp)
  add_test(NAME test_hello_lib COMMAND test_hello_lib)
  target_link_libraries(test_hello_lib PRIVATE hello_lib)
endif()
