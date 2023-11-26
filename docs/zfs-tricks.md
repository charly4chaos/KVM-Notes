# Disable sync

When you can life with some data loss on power outage, etc, disable sync
```bash
zfs set sync=disabled dataset/zvol
```