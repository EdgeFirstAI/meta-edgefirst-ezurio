# Name the EdgeFirst release in /etc/os-release next to Ezurio's own fields.
# A build without EDGEFIRST_VERSION keeps Ezurio's development build naming.

EDGEFIRST_PRETTY_NAME = "EdgeFirst Yocto ${EDGEFIRST_VERSION} for ${EDGEFIRST_VENDOR} BSP ${EDGEFIRST_BSP_VERSION}"
EDGEFIRST_BSP = "${EDGEFIRST_FEED_BSP}"

OS_RELEASE_FIELDS:append = "${@' EDGEFIRST_RELEASE EDGEFIRST_VERSION EDGEFIRST_BSP' if d.getVar('EDGEFIRST_VERSION') else ''}"

VERSION:summitsom = "${@d.getVar('EDGEFIRST_PRETTY_NAME') if d.getVar('EDGEFIRST_VERSION') else d.getVar('SUMMIT_RELEASE_STRING')}"
PRETTY_NAME:summitsom = "${@d.getVar('EDGEFIRST_PRETTY_NAME') if d.getVar('EDGEFIRST_VERSION') else d.getVar('SUMMIT_RELEASE_STRING')}"
