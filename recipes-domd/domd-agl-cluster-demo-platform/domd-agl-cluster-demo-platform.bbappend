FILESEXTRAPATHS_prepend := "${THISDIR}/../../inc:"
FILESEXTRAPATHS_prepend := "${THISDIR}/../domd-image-weston/files:"

###############################################################################
# extra layers and files to be put after Yocto's do_unpack into inner builder
###############################################################################
# these will be populated into the inner build system on do_unpack_xt_extras
# N.B. xt_shared_env.inc MUST be listed AFTER meta-xt-prod-extra
XT_QUIRK_UNPACK_SRC_URI += "\
    file://meta-xt-prod-extra;subdir=repo \
    file://xt_shared_env.inc;subdir=repo/meta-xt-prod-extra/inc \
    file://xen-version.inc;subdir=repo/meta-xt-prod-extra/recipes-extended/xen \
"

SRC_URI_rcar_append = " \
    repo://github.com/xen-troops/manifests;protocol=https;branch=master;manifest=prod_tu2019_demo/domd.xml;scmdata=keep \
"

# these layers will be added to bblayers.conf on do_configure
XT_QUIRK_BB_ADD_LAYER += "meta-xt-prod-extra"
XT_QUIRK_BB_ADD_LAYER += "meta-xt-agl-base"
# Override revision of AGL auxiliary layers
# N.B. the revision to use must be aligned with Poky's version of AGL to be built with
BRANCH = "thud"

# Dom0 is a generic ARMv8 machine w/o machine overrides,
# but still needs to know which system we are building,
# e.g. Salvator-X M3 or H3, for instance
# So, we provide machine overrides from this build the domain.
# The same is true for Android build.
addtask domd_install_machine_overrides after do_configure before do_compile
python do_domd_install_machine_overrides() {
    bb.debug(1, "Installing machine overrides")

    d.setVar('XT_BB_CMDLINE', "-f domd-install-machine-overrides")
    bb.build.exec_func("build_yocto_exec_bitbake", d)
}

################################################################################
# Renesas R-Car
################################################################################
SRCREV_agl-repo = "${AUTOREV}"
SRCREV_img-proprietary = "${AUTOREV}"

GLES_VERSION_rcar = "1.10"

configure_versions_rcar() {
    local local_conf="${S}/build/conf/local.conf"

    cd ${S}
    base_update_conf_value ${local_conf} PREFERRED_VERSION_xen "4.12.0+git\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_u-boot_rcar "v2018.09\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_linux-renesas "4.14.75+git\%"
    base_update_conf_value ${local_conf} PREFERRED_VERSION_linux-libc-headers "4.14.75+git\%"
    if [ -z ${XT_RCAR_EVAPROPRIETARY_DIR} ];then
        base_update_conf_value ${local_conf} PREFERRED_PROVIDER_gles-user-module "gles-user-module"
        base_update_conf_value ${local_conf} PREFERRED_VERSION_gles-user-module ${GLES_VERSION}

        base_update_conf_value ${local_conf} PREFERRED_PROVIDER_kernel-module-gles "kernel-module-gles"
        base_update_conf_value ${local_conf} PREFERRED_VERSION_gles-kernel-module ${GLES_VERSION}

        base_update_conf_value ${local_conf} PREFERRED_VERSION_gles-module-egl-headers ${GLES_VERSION}
        base_add_conf_value ${local_conf} EXTRA_IMAGEDEPENDS "prepare-graphic-package"
    else
        base_update_conf_value ${local_conf} PREFERRED_PROVIDER_virtual/libgles2 "rcar-proprietary-graphic"
        base_update_conf_value ${local_conf} PREFERRED_PROVIDER_virtual/egl "rcar-proprietary-graphic"
        base_set_conf_value ${local_conf} PREFERRED_PROVIDER_kernel-module-pvrsrvkm "rcar-proprietary-graphic"
        base_set_conf_value ${local_conf} PREFERRED_PROVIDER_kernel-module-dc-linuxfb "rcar-proprietary-graphic"
        base_set_conf_value ${local_conf} PREFERRED_PROVIDER_kernel-module-gles "rcar-proprietary-graphic"
        base_set_conf_value ${local_conf} PREFERRED_PROVIDER_gles-user-module "rcar-proprietary-graphic"
        base_set_conf_value ${local_conf} PREFERRED_PROVIDER_gles-module-egl-headers "rcar-proprietary-graphic"
        base_add_conf_value ${local_conf} BBMASK "meta-xt-images-vgpu/recipes-graphics/gles-module/"
        base_add_conf_value ${local_conf} BBMASK "meta-xt-prod-extra/recipes-graphics/gles-module/"
        base_add_conf_value ${local_conf} BBMASK "meta-xt-prod-vgpu/recipes-graphics/gles-module/"
        base_add_conf_value ${local_conf} BBMASK "meta-xt-prod-vgpu/recipes-graphics/wayland/"
        base_add_conf_value ${local_conf} BBMASK "meta-xt-prod-vgpu/recipes-kernel/kernel-module-gles/"
        base_add_conf_value ${local_conf} BBMASK "meta-xt-images-vgpu/recipes-kernel/kernel-module-gles/"
        base_add_conf_value ${local_conf} BBMASK "meta-renesas/meta-rcar-gen3/recipes-kernel/kernel-module-gles/"
        base_add_conf_value ${local_conf} BBMASK "meta-renesas/meta-rcar-gen3/recipes-graphics/gles-module/"
        xt_unpack_proprietary
    fi

    # Disable shared link for GO packages
    base_set_conf_value ${local_conf} GO_LINKSHARED ""

    # FIXME: normally bitbake fails with error if there are bbappends w/o recipes
    # which is the case for agl-demo-platform's recipe-platform while building
    # agl-image-weston: due to AGL's Yocto configuration recipe-platform is only
    # added to bblayers if building agl-demo-platform, thus making bitbake to
    # fail if this recipe is absent. Workaround this by allowing bbappends without
    # corresponding recipies.
    base_update_conf_value ${local_conf} BB_DANGLINGAPPENDS_WARNONLY "yes"
    
    # override console specified by default by the meta-rcar-gen3
    # to be hypervisor's one
    base_update_conf_value ${local_conf} SERIAL_CONSOLE "115200 hvc0"

    # set default timezone to Las Vegas
    base_update_conf_value ${local_conf} DEFAULT_TIMEZONE "US/Pacific"

    base_update_conf_value ${local_conf} XT_GUESTS_INSTALL "${XT_GUESTS_INSTALL}"

    if [ ! -z "${AOS_VIS_PLUGINS}" ];then
        base_update_conf_value ${local_conf} AOS_VIS_PLUGINS "${AOS_VIS_PLUGINS}"
    fi

    base_add_conf_value ${local_conf} ASSUME_PROVIDED "sync-native"
    base_add_conf_value ${local_conf} HOSTTOOLS "sync"
    base_add_conf_value ${local_conf} ASSUME_PROVIDED "bison-native"
    base_add_conf_value ${local_conf} HOSTTOOLS  "bison"
}

python do_configure_append_rcar() {
    bb.build.exec_func("configure_versions_rcar", d)
}

do_install_append () {
    local LAYERDIR=${TOPDIR}/../meta-xt-prod-tu2019-demo
    find ${LAYERDIR}/doc -iname "u-boot-env*" -exec cp -f {} ${DEPLOY_DIR}/domd-image-weston/images/${MACHINE}-xt \; || true
    if echo "${XT_GUESTS_INSTALL}" | grep -qi "domu";then
        find ${LAYERDIR}/doc -iname "mk_sdcard_image_domu.sh" -exec cp -f {} ${DEPLOY_DIR}/domd-image-weston/images/${MACHINE}-xt/mk_sdcard_image.sh \; \
        -exec cp -f {} ${DEPLOY_DIR}/mk_sdcard_image.sh \; || true
    else
        find ${LAYERDIR}/doc -iname "mk_sdcard_image.sh" -exec cp -f {} ${DEPLOY_DIR}/domd-image-weston/images/${MACHINE}-xt \; \
        -exec cp -f {} ${DEPLOY_DIR} \; || true
    fi
}
