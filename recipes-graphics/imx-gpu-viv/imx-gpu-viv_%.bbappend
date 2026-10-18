# libopenvx-imx depends on libopencl-imx-dev for the OpenVX intrinsic
# extension. The OpenCL runtime libraries are in libopencl-imx and nothing in
# the OpenVX stack links against the development package, which pulls in the
# GPU, Wayland, XML and Python development packages. Keep the runtime pair.
OPENCL_VX_INTRINSIC_EXTENSION_PACKAGES:mx8mp-nxp-bsp = "libclc-imx libopencl-imx"

# OpenVX compiles its EVIS kernels at runtime and includes cl_viv_vx_ext.h to
# do it; without the header the kernels fall back to a much slower path. The
# header is only packaged in libopencl-imx-dev, which is too large to ship, so
# give it a package of its own. Anything that installs the development package
# still gets it through the dependency.
PACKAGES:prepend:mx8mp-nxp-bsp = "${PN}-vx-ext-header "
FILES:${PN}-vx-ext-header = "${includedir}/CL/cl_viv_vx_ext.h"
RDEPENDS:libopencl-imx-dev:append:mx8mp-nxp-bsp = " ${PN}-vx-ext-header"
