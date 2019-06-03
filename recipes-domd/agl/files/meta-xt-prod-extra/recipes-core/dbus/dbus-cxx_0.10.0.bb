DESCRIPTION = "C++ bindings for dbus"
HOMEPAGE = "https://dbus-cxx.github.io/"
SECTION = "libs"
LICENSE = "GPLv3"
DEPENDS = "boost dbus libsigc++-2.0"

SRC_URI = "git://github.com/dbus-cxx/${PN}.git;nobranch=1;tag=${PV}"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

S = "${WORKDIR}/git"

inherit autotools-brokensep pkgconfig

BBCLASSEXTEND = "native"
DEPENDS_virtclass-native = "dbus-native libsigc++-2.0-native"