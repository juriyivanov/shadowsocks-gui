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

set(_qt_components Core Gui Widgets Network)
if(UNIX AND NOT APPLE)
    list(APPEND _qt_components DBus)
endif()

# Prefer Qt 6 but fall back to a Qt 5 toolchain if available.
find_package(Qt6 COMPONENTS ${_qt_components} QUIET)
if(Qt6_FOUND)
    set(QT_PACKAGE_PREFIX Qt6)
else()
    find_package(Qt5 COMPONENTS ${_qt_components} QUIET)
    if(NOT Qt5_FOUND)
        set(_missing_components "Core/Gui/Widgets/Network")
        if(UNIX AND NOT APPLE)
            string(APPEND _missing_components "/DBus")
        endif()
        message(FATAL_ERROR "Neither Qt 6 nor Qt 5 (${_missing_components}) was found. Install the matching Qt development files and set Qt6_DIR/Qt5_DIR or CMAKE_PREFIX_PATH if they are not in the default location.")
    endif()
    set(QT_PACKAGE_PREFIX Qt5)
endif()

find_package(PkgConfig REQUIRED)

# Prefer the Qt 6 pkg-config name used by recent libQtShadowsocks releases
if(QT_PACKAGE_PREFIX STREQUAL "Qt6")
    pkg_check_modules(QSS_QT QtShadowsocks-qt6>=2.0.0)
    if(NOT QSS_QT_FOUND)
        # Fallback to the legacy name but keep the Qt 6 requirement explicit so
        # a Qt 5 build of the library is rejected early.
        pkg_check_modules(QSS_QT QtShadowsocks>=2.0.0)
        if(NOT QSS_QT_FOUND)
            message(FATAL_ERROR "libQtShadowsocks (Qt 6 build) was not found. Install a Qt 6 build of the library and ensure its pkg-config file is discoverable.")
        endif()
    endif()
else()
    # Qt 5 builds are only used when Qt 6 is unavailable; accept either the qt5
    # or legacy pkg-config name.
    pkg_check_modules(QSS_QT QtShadowsocks-qt5 QtShadowsocks)
    if(NOT QSS_QT_FOUND)
        message(FATAL_ERROR "libQtShadowsocks (Qt 5 build) was not found. Install a Qt 5 build of the library and ensure its pkg-config file is discoverable.")
    endif()
endif()

foreach(_field INCLUDE_DIRS LIBRARIES LIBDIR LIBRARY_DIRS)
    set(QSS_${_field} ${QSS_QT_${_field}})
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
