# Remove all rotated portrait mode config fragments, and add our own
# instead, as the cluster demo display is landscape orientation.
FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_remove = " \
    file://hdmi-a-1-180.cfg \
    file://virtual-landscape.cfg \
    file://kingfisher_output.cfg \
"

SRC_URI += " \
    file://hdmi-a-1-0.cfg \
    file://hdmi-a-2-0.cfg \
    file://vga-1-off.cfg \
    file://lvds-1-off.cfg \
"
