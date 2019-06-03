FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV = "${AUTOREV}"

SRC_URI_append = " \
    git://github.com/xen-troops/DisplayManager.git;protocol=https;branch=tu2019-demo \
    file://display_manager.conf \
"

DEPENDS = "libconfig wayland-ivi-extension dbus-cxx git-native xt-log"

EXTRA_OECMAKE_append = " -DWITH_DOC=OFF -DCMAKE_BUILD_TYPE=Release"

do_install_append() {
    install -d ${D}${sysconfdir}/dbus-1/session.d
    install -m 0755 ${WORKDIR}/display_manager.conf ${D}${sysconfdir}/dbus-1/session.d/
}

FILES_${PN} += " \
    ${sysconfdir}/dbus-1/session.d/display_manager.conf \
"
