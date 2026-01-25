resource "talos_image_factory_schematic" "gpu" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/intel-ucode",
          "siderolabs/i915-ucode"
        ]
      }
    }
  })
}

output "gpu_installer_url" {
  value = "factory.talos.dev/installer/${talos_image_factory_schematic.gpu.id}:v1.12.0"
}
