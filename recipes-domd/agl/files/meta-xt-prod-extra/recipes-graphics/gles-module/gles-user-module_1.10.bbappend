FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
require inc/xt_shared_env.inc

BRANCH = "1.10/ED5187610_GCC-8"
SRCREV = "${AUTOREV}"
SRC_URI_append = " \
    file://0001-Make-compiler-target-aarch64-agl-linux-be-recognized.patch \
"
