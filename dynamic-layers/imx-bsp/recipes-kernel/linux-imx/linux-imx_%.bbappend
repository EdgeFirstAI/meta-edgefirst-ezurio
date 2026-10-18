FILESEXTRAPATHS:prepend := "${THISDIR}/linux-imx:"

# Applied by do_patch:append rather than by the fetcher: the Summit device
# trees are copied over the kernel tree after the normal patch step.
SRC_URI:append:mx8mp-generic-bsp:summitsom = " file://0001-edgefirst-imx8mp-enable-gpu-npu-nodes.patch;apply=no"
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0002-edgefirst-imx95-enable-neutron-npu.patch;apply=no"
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0069-neutron-fix-rproc-probe-race-null-deref.patch"

# eIQ Neutron SDK 3.2.x firmware speaks a mailbox protocol the neutron driver
# in this 6.12.49 kernel does not: it replies 0xA1 to a reset where the driver
# expects 0x0, and waits until its retry budget expires, leaving the NPU
# unusable. NXP reworked the handshake in the 6.18.37 BSP (lf-6.18.37-2.1.0);
# this is that commit, backported unmodified.
#
# The handshake is a version lock, not an additive change: the reset reply
# 0xA1 becomes mandatory, so this kernel requires 3.2.x firmware and will not
# drive 3.1.x. That is safe here because the neutron recipe installs the
# firmware, library and headers from one SDK tree, so a rootfs cannot mix
# generations, and the kernel and firmware are written to the same A/B slot by
# one .swu.
#
# Scoped to i.MX 95 because drivers/staging/neutron exists only on the SoCs
# that carry the Neutron NPU. Drop this once the Ezurio BSP kernel carries the
# change.
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0070-staging-neutron-rework-driver-firmware-mailbox-handshake.patch"

do_patch:append:mx8mp-generic-bsp:summitsom () {
    patch -p1 -d "${S}" < "${UNPACKDIR}/0001-edgefirst-imx8mp-enable-gpu-npu-nodes.patch"
}

do_patch:append:mx95-generic-bsp:summitsom () {
    patch -p1 -d "${S}" < "${UNPACKDIR}/0002-edgefirst-imx95-enable-neutron-npu.patch"
}
