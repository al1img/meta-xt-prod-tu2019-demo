do_install_append() {
    if [ "X${USE_GLES}" = "X1" ]; then
        sed -i "/EnvironmentFile=-\/etc\/default\/weston/a ExecStartPre=\/bin\/chmod 700 \/run\/platform\/display" \
                ${D}/${systemd_system_unitdir}/weston.service
    fi
}
