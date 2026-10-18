SUMMARY = "DRM device for GPU access without a display"
DESCRIPTION = "The Mali userspace opens a DRM node for GBM and EGL buffer \
allocation, but the i.MX 95 display controller stays disabled until an overlay \
enables a panel. VGEM registers a render node with no connectors and no \
framebuffer, so headless units get /dev/dri without Weston or any display \
appearing."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://vgem.conf"
S = "${UNPACKDIR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install () {
    install -d ${D}${nonarch_libdir}/modules-load.d
    install -m 0644 ${UNPACKDIR}/vgem.conf ${D}${nonarch_libdir}/modules-load.d/vgem.conf
}

FILES:${PN} = "${nonarch_libdir}/modules-load.d/vgem.conf"
RDEPENDS:${PN} = "kernel-module-vgem"
