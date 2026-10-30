# Name the EdgeFirst release in /etc/os-release next to Ezurio's own fields.
# meta-edgefirst adds the same fields only for images that update with apt, so
# they are added here for the SWUpdate images. Ezurio sets the name and version
# through machine overrides, which win over its plain assignments, so the
# EdgeFirst name is set through the same override. A build without
# EDGEFIRST_VERSION is named as an EdgeFirst development build, with Ezurio's
# build timestamp.

EDGEFIRST_PRETTY_NAME = "EdgeFirst Yocto ${EDGEFIRST_VERSION} for ${EDGEFIRST_VENDOR} BSP ${EDGEFIRST_BSP_VERSION}"
EDGEFIRST_BSP = "${EDGEFIRST_FEED_BSP}"

OS_RELEASE_FIELDS:append = "${@' EDGEFIRST_RELEASE EDGEFIRST_VERSION EDGEFIRST_BSP' if d.getVar('EDGEFIRST_VERSION') else ''}"

EDGEFIRST_DEV_NAME = "${@d.getVar('SUMMIT_RELEASE_STRING').replace('Summit Linux', 'EdgeFirst Yocto for Ezurio EZ BSP')}"

NAME:summitsom = "EdgeFirst Yocto for Ezurio"
VERSION:summitsom = "${@d.getVar('EDGEFIRST_PRETTY_NAME') if d.getVar('EDGEFIRST_VERSION') else d.getVar('EDGEFIRST_DEV_NAME')}"
PRETTY_NAME:summitsom = "${@d.getVar('EDGEFIRST_PRETTY_NAME') if d.getVar('EDGEFIRST_VERSION') else d.getVar('EDGEFIRST_DEV_NAME')}"
