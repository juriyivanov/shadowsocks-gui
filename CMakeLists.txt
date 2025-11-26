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

find_package(PkgConfig REQUIRED)

# Prefer the Qt 6 pkg-config name used by recent libQtShadowsocks releases
pkg_check_modules(QSS_QT6 QtShadowsocks-qt6>=2.0.0)
if(QSS_QT6_FOUND)
    set(_QSS_PREFIX QSS_QT6)
else()
    # Fallback to the legacy name but keep the Qt 6 requirement explicit so
    # a Qt 5 build of the library is rejected early.
    pkg_check_modules(QSS_QTLEGACY QtShadowsocks>=2.0.0)
    if(NOT QSS_QTLEGACY_FOUND)
        message(FATAL_ERROR "libQtShadowsocks (Qt 6 build) was not found. Install a Qt 6 build of the library and ensure its pkg-config file is discoverable.")
    endif()
    set(_QSS_PREFIX QSS_QTLEGACY)
endif()

foreach(_field INCLUDE_DIRS LIBRARIES LIBDIR LIBRARY_DIRS)
    set(QSS_${_field} ${${_QSS_PREFIX}_${_field}})
endforeach()

find_library(QSS_LIBRARY_VAR
    NAMES ${QSS_LIBRARIES}
    HINTS ${QSS_LIBRARY_DIRS} ${QSS_LIBDIR})
if(NOT QSS_LIBRARY_VAR)
    message(FATAL_ERROR "libQtShadowsocks library binary was not found; check that the Qt 6 build is installed and pkg-config paths are set.")
endif()

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
