# meta-edgefirst adds the EdgeFirst fields to /etc/os-release. Ezurio sets the
# name and version through machine overrides, which win over its plain
# assignments, so the EdgeFirst name is set through the same override. A build
# without EDGEFIRST_VERSION keeps Ezurio's development build naming.

EDGEFIRST_PRETTY_NAME = "EdgeFirst Yocto ${EDGEFIRST_VERSION} for ${EDGEFIRST_VENDOR} BSP ${EDGEFIRST_BSP_VERSION}"

VERSION:summitsom = "${@d.getVar('EDGEFIRST_PRETTY_NAME') if d.getVar('EDGEFIRST_VERSION') else d.getVar('SUMMIT_RELEASE_STRING')}"
PRETTY_NAME:summitsom = "${@d.getVar('EDGEFIRST_PRETTY_NAME') if d.getVar('EDGEFIRST_VERSION') else d.getVar('SUMMIT_RELEASE_STRING')}"
