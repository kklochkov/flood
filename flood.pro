TEMPLATE = lib
TARGET = flood
QT += declarative
CONFIG += qt plugin

TARGET = $$qtLibraryTarget($$TARGET)
uri = flood

# Input
SOURCES += \
    flood_plugin.cpp \
    flood.cpp

HEADERS += \
    flood_plugin.h \
    flood.h

OTHER_FILES = qmldir \
    *.qml \
    main.qml \
    Button.qml \
    Dialog.qml

QML_FILES = *.qml

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir *.qml
symbian {
    TARGET.EPOCALLOWDLLDATA = 1
} else:unix {
    installPath = /usr/local/Trolltech/Qt-4.7.3/imports/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}
