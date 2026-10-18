SUMMARY = "EdgeFirst runtime for Ezurio Nitrogen SMARC"
DESCRIPTION = "The EdgeFirst capability groups for NPU, camera, Studio agents and \
diagnostics, plus the Ezurio camera setup and 2D blitter. No GStreamer, \
NNStreamer, Python or ONNX."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    packagegroup-edgefirst-npu \
    packagegroup-edgefirst-studio \
    packagegroup-edgefirst-camera \
    packagegroup-edgefirst-diagnostics \
    summit-camera-setup \
    summit-set-mode \
"

# The Ezurio DVK group adds Python and python3-dbus-fast, which are not needed
# here; this is its remaining member that applies to the Nitrogen machines.
RDEPENDS:${PN}:append:mx9-generic-bsp = " kernel-module-pivariety"

# The 2D blitter and the OpenVX EVIS kernel header are not part of the
# capability groups; the NPU delegate, Neutron runtime, libcamera ISP IPA and
# the client and profiler come from them.
RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " imx-gpu-g2d imx-gpu-viv-vx-ext-header"
