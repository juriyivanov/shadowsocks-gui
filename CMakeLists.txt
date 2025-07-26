cmake_minimum_required(VERSION 3.16)

project(shadowsocks-gui
    VERSION 3.0.1
    LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find Qt 6 components
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Network DBus)

find_package(PkgConfig)

pkg_check_modules(QSS REQUIRED QtShadowsocks>=2.0.0)
find_library(QSS_LIBRARY_VAR
    NAMES ${QSS_LIBRARIES}
    HINTS ${QSS_LIBRARY_DIRS} ${QSS_LIBDIR})

pkg_check_modules(QRENCODE REQUIRED libqrencode)
find_library(QRENCODE_LIBRARY_VAR
    NAMES ${QRENCODE_LIBRARIES}
    HINTS ${QRENCODE_LIBRARY_DIRS} ${QRENCODE_LIBDIR})

pkg_check_modules(ZBAR REQUIRED zbar)
find_library(ZBAR_LIBRARY_VAR
    NAMES ${ZBAR_LIBRARIES}
    HINTS ${ZBAR_LIBRARY_DIRS} ${ZBAR_LIBDIR})

if(WIN32 OR APPLE)
    add_definitions(-DFD_SETSIZE=1024)
endif()

add_subdirectory(src)
