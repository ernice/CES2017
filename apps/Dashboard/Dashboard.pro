TEMPLATE = app
TARGET = dashboard
QT = quickcontrols2 websockets

config_libhomescreen {
    CONFIG += link_pkgconfig
    PKGCONFIG += homescreen
    DEFINES += HAVE_LIBHOMESCREEN
}

SOURCES = main.cpp \
    usermanagement.cpp

RESOURCES += \
    dashboard.qrc \
    images/images.qrc

HEADERS += \
    usermanagement.h
