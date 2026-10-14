# NXP's recipe ships the TFLite Python wheel and example in the runtime
# package and depends on python3 and numpy for them. EdgeFirst uses the C++
# library, so leave the Python bindings out of the image.
PACKAGECONFIG:remove = "python-example"
RDEPENDS:${PN}:remove = "python3 python3-numpy"

do_install:append() {
    rm -rf ${D}${PYTHON_SITEPACKAGES_DIR}
}
