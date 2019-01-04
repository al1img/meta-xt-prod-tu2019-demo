FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://default.pa"

do_compile_append () {
    sed -i "/ConditionUser=\!root/d" \
    ${B}/src/pulseaudio.service
}

do_install_append () {
    cp ${WORKDIR}/default.pa ${D}${sysconfdir}/pulse/default.pa
}
