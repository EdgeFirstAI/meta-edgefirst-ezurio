FILESEXTRAPATHS:prepend := "${THISDIR}/linux-imx:"

# Applied by do_patch:append rather than by the fetcher: the Summit device
# trees are copied over the kernel tree after the normal patch step.
SRC_URI:append:mx8mp-generic-bsp:summitsom = " file://0001-edgefirst-imx8mp-enable-gpu-npu-nodes.patch;apply=no"
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0002-edgefirst-imx95-enable-neutron-npu.patch;apply=no"
SRC_URI:append:mx95-generic-bsp:summitsom = " file://0069-neutron-fix-rproc-probe-race-null-deref.patch"

do_patch:append:mx8mp-generic-bsp:summitsom () {
    patch -p1 -d "${S}" < "${UNPACKDIR}/0001-edgefirst-imx8mp-enable-gpu-npu-nodes.patch"
}

do_patch:append:mx95-generic-bsp:summitsom () {
    patch -p1 -d "${S}" < "${UNPACKDIR}/0002-edgefirst-imx95-enable-neutron-npu.patch"
}
