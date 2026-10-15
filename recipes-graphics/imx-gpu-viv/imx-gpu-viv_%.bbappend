# libopenvx-imx depends on libopencl-imx-dev for the OpenVX intrinsic
# extension. The OpenCL runtime libraries are in libopencl-imx and nothing in
# the OpenVX stack links against the development package, which pulls in the
# GPU, Wayland, XML and Python development packages. Keep the runtime pair.
OPENCL_VX_INTRINSIC_EXTENSION_PACKAGES:mx8mp-nxp-bsp = "libclc-imx libopencl-imx"
