# meta-edgefirst-ezurio

EdgeFirst changes for Ezurio Nitrogen SMARC boards (`imx8mp-nitrogen-smarc-4g`, `imx95-nitrogen-smarc`) on Ezurio's `SUMMIT-REL-6.16.0.27` BSP (walnascar). It sits on top of Ezurio's `meta-summit-som` and [meta-edgefirst](https://github.com/EdgeFirstAI/meta-edgefirst), and is built through the [EdgeFirstAI/yocto](https://github.com/EdgeFirstAI/yocto) `edgefirst-ezurio-6.16.0.27` branch. Ezurio's layers are used unmodified.

## Image

`image-edgefirst` follows Ezurio's `image-summitsom-weston` and produces the same outputs (`.wic.bz2`, `.wic.bmap`, `.swu`) with the same A/B SWUpdate layout. It replaces `packagegroup-summit-camera` (which pulls in all of GStreamer) with `packagegroup-edgefirst-runtime`: TFLite with the VX (i.MX 8M Plus) or Neutron (i.MX 95) delegate, V4L2 and libcamera, `edgefirst-client` and `edgefirst-profiler`. GStreamer, NNStreamer, Python and ONNX are not installed.

## Fixes for Ezurio's BSP

| Change | Reason |
|---|---|
| `0001-…-imx8mp-enable-gpu-npu-nodes.patch` | The GPU, VPU and NPU device-tree nodes are `disabled` in the default Nitrogen i.MX 8M Plus device tree, so `galcore` finds no device |
| `0002-…-imx95-enable-neutron-npu.patch` | The Neutron nodes are `disabled` in the default Nitrogen i.MX 95 device tree |
| `0069-neutron-fix-rproc-probe-race-null-deref.patch` | The Neutron driver caches a failed remoteproc lookup and dereferences NULL at probe |
| `install_kernel_module_imx_gpu_viv` in `image-edgefirst` | The `galcore` package name is only known at `do_package` time and never reaches the rootfs feed |
| `FIT_KERNEL_COMP_ALG = "none"` on i.MX 8M Plus | The deployed bootloader may lack ZSTD support |
| `KERNEL_DEVICETREE:remove` of the Neutron overlay on i.MX 95 | The nodes are enabled in the base device tree instead |

The device-tree patches are applied by `do_patch:append`, because Ezurio copies its device trees over the kernel tree after the normal patch step.
