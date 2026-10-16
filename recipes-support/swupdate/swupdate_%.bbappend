FILESEXTRAPATHS:prepend := "${THISDIR}/swupdate:"

# Signature checking is built in only for signed release builds, so a plain
# development build still accepts unsigned packages.
SRC_URI:append = "${@' file://edgefirst-signing.cfg' if d.getVar('EDGEFIRST_CERT_PATH') else ''}"
