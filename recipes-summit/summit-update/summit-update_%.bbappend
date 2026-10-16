EDGEFIRST_ROOT_CERT = "${EDGEFIRST_CERT_PATH}/root/edgefirst-root.crt.pem"

do_install[file-checksums] += "${@'${EDGEFIRST_ROOT_CERT}:True' if d.getVar('EDGEFIRST_CERT_PATH') else ''}"

# The device trusts the EdgeFirst root; each vendor's intermediate travels in
# the CMS signature of the package, so adding or rotating a signing leaf needs
# no change on the device.
do_install:append () {
    if [ -n "${EDGEFIRST_CERT_PATH}" ]; then
        if [ ! -f "${EDGEFIRST_ROOT_CERT}" ]; then
            bbfatal "EdgeFirst root certificate not found: ${EDGEFIRST_ROOT_CERT}"
        fi
        install -D -m 0644 "${EDGEFIRST_ROOT_CERT}" \
            "${D}${sysconfdir}/swupdate/edgefirst-root.crt.pem"
        echo "SWUPDATE_ARGS=\"\${SWUPDATE_ARGS} -k ${sysconfdir}/swupdate/edgefirst-root.crt.pem\"" > \
            "${D}${sysconfdir}/swupdate/conf.d/11-signing.conf"
    fi
}
