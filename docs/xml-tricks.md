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