# No explanations in this file, check here!
Read here for explanation what each option does: [XML format documentation from libvirt](https://libvirt.org/formatdomain.html)

# Custom tags for the scripts

Define custom tags to be evaluated by the hook scripts:
```xml
  <metadata>
      <chaos:chaos xmlns:chaos="https://raw.githubusercontent.com/charly4chaos/KVM-Notes/main/data/libvirt-chaos.xsd">
          <chaos:tag name="cpu-isolation" />
          <chaos:tag name="display-toggle" />
      </chaos:chaos>
  </metadata>
```

# Disk configuration
## Virtio-SCSI disk
<details>
<summary>On my system was an problem with virtio-scsi and QEMU emulator version 7.2.5, so I did not use virtio-scsi</summary>

The disk
```xml
<disk type="block" device="disk">
  <driver name="qemu" type="raw" cache="none" io="native" discard="unmap"/>
  <source dev="/dev/zvol/your-zvol"/>
  <target dev="sdd" bus="scsi"/>
  <address type="drive" controller="0" bus="0" target="0" unit="3"/>
</disk>
```
The controller
```xml
<controller type="scsi" index="0" model="virtio-scsi">
  <driver queues="4" iothread="1"/>
  <address type="pci" domain="0x0000" bus="0x06" slot="0x00" function="0x0"/>
</controller>
```
</details>

## Virtio disk
```xml
<disk type="block" device="disk">
  <driver name="qemu" type="raw" cache="none" io="native" discard="unmap" iothread="1" queues="4"/>
  <source dev="/dev/zvol/your-zvol"/>
  <target dev="vda" bus="virtio"/>
  <boot order="1"/>
  <address type="pci" domain="0x0000" bus="0x0b" slot="0x00" function="0x0"/>
</disk>
```
## Troubleshooting
Workaround for possible error (virtio-blk & zfs?): is discard="ignore" https://gitlab.com/qemu-project/qemu/-/issues/1404, https://gitlab.com/qemu-project/qemu/-/issues/649

# Looking-Glass
There is a bug which prevents starting the vm when adding `shmem` device.
```xml
<shmem name='looking-glass'>
  <model type='ivshmem-plain'/>
  <size unit='M'>256</size>
</shmem>
```

The workaround is described here: https://github.com/tianocore/edk2/discussions/4662
```xml
<cpu>
  <maxphysaddr mode='passthrough' limit='39'/>
</cpu>
```