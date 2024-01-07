#!/bin/bash
if [ $(whoami) != "root" ]; then
    echo "Restart as root"
    sudo $0 $@
    exit $!
fi
PROJECTDIR=$(dirname "${0}")/..
COMMAND=${1:-INVALID}

function exit_with_message {
    echo "${1}"
    exit ${2:-0}
}

case ${COMMAND} in
    "hooks")
        rsync -rv ${PROJECTDIR}/root/etc/libvirt/hooks/ /etc/libvirt/hooks || exit_with_message "Error copying files" 1
        find /etc/libvirt/hooks -type f -exec chmod 755 {} \; 
        find /etc/libvirt/hooks -type d -exec chmod 755 {} \; 
        find /etc/libvirt/hooks         -exec chown root:root {} \; 
        echo Files:
        ls -l /etc/libvirt/hooks/*
        ;;
    "udev")
        rsync -rv ${PROJECTDIR}/root/etc/udev/rules.d/ /etc/udev/rules.d || exit_with_message "Error copying files" 1
        find /etc/libvirt/hooks -type f -exec chmod 644 {} \; 
        find /etc/libvirt/hooks         -exec chown root:root {} \; 
        echo Files:
        ls -l /etc/udev/rules.d/*
        ;;
    *) 
    echo "Command ${COMMAND} unknown."
    exit 1;;
esac