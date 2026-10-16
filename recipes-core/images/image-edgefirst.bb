DESCRIPTION = "EdgeFirst image for Ezurio Nitrogen SMARC"

FILESEXTRAPATHS:prepend := "${SUMMIT_SOM_LAYERDIR}/recipes-summit/images/files/nomcu:${SUMMIT_SOM_LAYERDIR}/recipes-summit/images/files:"

inherit image-summitsom-gen image-summitsom-sd-gen image-summitsom-swu-gen

IMAGE_FEATURES += "splash hwcodecs weston"

EDGEFIRST_VENDOR_CA_DIR = "${EDGEFIRST_SIGNING_CERT_PATH}/${EDGEFIRST_SIGNING_VENDOR}"
SWUPDATE_SIGNING = "${@'CMS' if d.getVar('EDGEFIRST_SIGNING_CERT_PATH') else ''}"
SWUPDATE_CMS_KEY = "${EDGEFIRST_VENDOR_CA_DIR}/private/${EDGEFIRST_SIGNING_LEAF}.key.pem"
SWUPDATE_CMS_CERT = "${EDGEFIRST_VENDOR_CA_DIR}/${EDGEFIRST_SIGNING_LEAF}.cert.pem"
SWUPDATE_CMS_EXTRA_CERTS = "${EDGEFIRST_VENDOR_CA_DIR}/edgefirst-${EDGEFIRST_SIGNING_VENDOR}.crt.pem"

IMAGE_INSTALL += "\
    packagegroup-summit-basic \
    packagegroup-summit-diag \
    packagegroup-edgefirst-runtime \
    "

# kernel-module-imx-gpu-viv's payload is a kernel-ABI-suffixed sub-package
# created at do_package time, so it never resolves into the rootfs feed. Copy
# the already-built module into the rootfs directly.
IMAGE_INSTALL:append:mx8mp-nxp-bsp = " kernel-module-imx-gpu-viv"
GALCORE_ROOTFS_DEPENDS = ""
GALCORE_ROOTFS_DEPENDS:mx8mp-nxp-bsp = "kernel-module-imx-gpu-viv:do_package_write_ipk"
do_rootfs[depends] += "${GALCORE_ROOTFS_DEPENDS}"

install_kernel_module_imx_gpu_viv () {
    moduledir=$(find "${TMPDIR}/work" -maxdepth 3 -type d -name "kernel-module-imx-gpu-viv" 2>/dev/null | head -n1)
    if [ -z "$moduledir" ]; then
        bbfatal "kernel-module-imx-gpu-viv has not been built"
    fi
    splitdir=$(find "$moduledir" -maxdepth 3 -type d -path "*/packages-split/kernel-module-galcore-*" 2>/dev/null | sort -V | tail -n1)
    if [ -z "$splitdir" ]; then
        bbfatal "kernel-module-galcore split package not found under $moduledir"
    fi
    install -d ${IMAGE_ROOTFS}${nonarch_base_libdir}/modules
    cp -a "$splitdir"${nonarch_base_libdir}/modules/. ${IMAGE_ROOTFS}${nonarch_base_libdir}/modules/
    if [ -d "$splitdir"${nonarch_libdir}/modules-load.d ]; then
        install -d ${IMAGE_ROOTFS}${nonarch_libdir}/modules-load.d
        cp -a "$splitdir"${nonarch_libdir}/modules-load.d/. ${IMAGE_ROOTFS}${nonarch_libdir}/modules-load.d/
    fi
}
ROOTFS_POSTPROCESS_COMMAND:append:mx8mp-nxp-bsp = " install_kernel_module_imx_gpu_viv;"
