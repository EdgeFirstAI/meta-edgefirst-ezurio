FILESEXTRAPATHS:prepend := "${THISDIR}/linux-imx:"

# Applied by do_patch:append rather than by the fetcher: the Summit device
# trees are copied over the kernel tree after the normal patch step.
SRC_URI:append:mx8mp-generic-bsp:summitsom = " file://0001-edgefirst-imx8mp-enable-gpu-npu-nodes.patch;apply=no"
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0002-edgefirst-imx95-enable-neutron-npu.patch;apply=no"
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0069-neutron-fix-rproc-probe-race-null-deref.patch"

# eIQ Neutron SDK 3.2.x firmware replies 0xA1 to a mailbox reset where this
# kernel's driver expects 0x0 and would wait out its retry budget, leaving the
# NPU unusable. This is NXP's handshake rework from lf-6.18.37-2.1.0, applied
# unmodified; drop it once the BSP kernel carries it. The driver then requires
# 3.2.x firmware, which the neutron recipe installs together with the library.
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0070-staging-neutron-rework-driver-firmware-mailbox-handshake.patch"

do_patch:append:mx8mp-generic-bsp:summitsom () {
    patch -p1 -d "${S}" < "${UNPACKDIR}/0001-edgefirst-imx8mp-enable-gpu-npu-nodes.patch"
}

do_patch:append:mx95-generic-bsp:summitsom () {
    patch -p1 -d "${S}" < "${UNPACKDIR}/0002-edgefirst-imx95-enable-neutron-npu.patch"
}
