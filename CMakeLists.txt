cmake_minimum_required(VERSION 3.16)

project(SimplePasswordManager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)
# ZLIB/QUAZIP
find_package(ZLIB)

set(CMAKE_AUTORCC ON)

set(QUAZIPCODEDIR "D:/dev/cpp/zip/quazip-1.4/quazip")
set(ZLIBCODEDIR "D:/dev/cpp/zip/libs")

include_directories(ZLIB ${ZLIBCODEDIR})
include_directories(QUAZIP ${QUAZIPCODEDIR})
# end
# Qt-AES
#include_directories(Qt-AES ${CMAKE_CURRENT_SOURCE_DIR}/aesni)
# end
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appSimplePasswordManager
    main.cpp
    qml.qrc
    spmmodel.h
    spmmodel.cpp
    qclipboardqtquickwrapper.h
    localmodelloader.h
    localmodelloader.cpp
    qaesencryption.h
    qaesencryption.cpp
    sessionmanager.h
    sessionmanager.cpp
)

qt_add_qml_module(appSimplePasswordManager
    URI SimplePasswordManager
    VERSION 1.0
    QML_FILES Main.qml
)

set_target_properties(appSimplePasswordManager PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSimplePasswordManager
    PRIVATE Qt6::Quick
    # ZLIB/QUAZIP
    ZLIB::ZLIB
    quazip1-qt6
    # end
)

install(TARGETS appSimplePasswordManager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
