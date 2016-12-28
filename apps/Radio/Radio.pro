TEMPLATE = app
TARGET = radio
QT = quickcontrols2

load(configure)
qtCompileTest(libhomescreen)

config_libhomescreen {
    CONFIG += link_pkgconfig
    PKGCONFIG += homescreen
    DEFINES += HAVE_LIBHOMESCREEN
}

HEADERS = PresetDataObject.h
SOURCES = main.cpp PresetDataObject.cpp

RESOURCES += \
    radio.qrc \
    images/images.qrc

