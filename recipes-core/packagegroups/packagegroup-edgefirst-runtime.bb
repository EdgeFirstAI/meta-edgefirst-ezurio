SUMMARY = "EdgeFirst runtime for Ezurio Nitrogen SMARC"
DESCRIPTION = "The EdgeFirst capability groups for the NPU, graphics and Weston, \
video codecs, camera, Studio agents and diagnostics, plus the Ezurio camera \
setup. No GStreamer, NNStreamer, Python or ONNX."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    packagegroup-edgefirst-npu \
    packagegroup-edgefirst-graphics \
    packagegroup-edgefirst-codec \
    packagegroup-edgefirst-studio \
    packagegroup-edgefirst-camera \
    packagegroup-edgefirst-diagnostics \
    summit-camera-setup \
    summit-set-mode \
"

# The Ezurio DVK group adds Python and python3-dbus-fast, which are not needed
# here; this is its remaining member that applies to the Nitrogen machines.
RDEPENDS:${PN}:append:mx9-generic-bsp = " kernel-module-pivariety edgefirst-headless-drm"

# The OpenVX EVIS kernel header is not part of the capability groups; the GPU
# and 2D blitter, NPU delegate, Neutron runtime, video codec userspace,
# libcamera ISP IPA and the client and profiler come from them.
RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " imx-gpu-viv-vx-ext-header"
