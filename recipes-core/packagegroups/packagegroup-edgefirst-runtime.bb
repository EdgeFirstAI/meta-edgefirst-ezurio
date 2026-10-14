SUMMARY = "EdgeFirst runtime for Ezurio Nitrogen SMARC"
DESCRIPTION = "TFLite with the NPU delegate for the SoC, a minimal V4L2 and \
libcamera camera stack, and the EdgeFirst client and profiler. No GStreamer, \
NNStreamer, Python or ONNX."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    edgefirst-client \
    edgefirst-profiler \
    tensorflow-lite \
    libcamera \
    v4l-utils \
    summit-camera-setup \
    summit-set-mode \
"

# The Ezurio DVK group adds Python and python3-dbus-fast, which are not needed
# here; this is its remaining member that applies to the Nitrogen machines.
RDEPENDS:${PN}:append:mx9-generic-bsp = " kernel-module-pivariety"

RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " \
    tensorflow-lite-vx-delegate \
    imx-gpu-g2d \
"

RDEPENDS:${PN}:append:mx95-nxp-bsp = " \
    tensorflow-lite-neutron-delegate \
    neutron \
"
