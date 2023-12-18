#!/bin/sh
# Try to toggle displays
# Only takes vms in consideration which use the chaos:display-toggle
DOMAIN=$1
COMMAND=$2
CONFIGFILE=/etc/libvirt/qemu/${DOMAIN}.xml

. $(dirname $0)/helper.sh

XPATH_TOGGLE='/domain/metadata/*[name()="chaos:chaos"]/*[name()="chaos:display-toggle"]'
# Check if tag is set for display-toggle
if ! xmllint --xpath "${XPATH_TOGGLE}" ${CONFIGFILE} 1>/dev/null 2>/dev/null  ; then
	echo Display-toggle not enabled for ${DOMAIN}.
	exit 0
fi

# Check if PCI-Passthrough is used
if ! xmllint --xpath '/domain/devices/hostdev[@type="pci"]' ${CONFIGFILE} 1>/dev/null 2>/dev/null ; then
	echo No GPU passthrough found for ${DOMAIN}.
	exit 0
fi

echo Try display-toggle for ${DOMAIN}

export DISPLAY_HOST_DEDICATED=HDMI-2
export DISPLAY_SHARED_WITH_VM=HDMI-1

export DISPLAY=$(getXwaylandDisplay)
export USER=$(getXwaylandXUser)
export XAUTHORITY=$(getXwaylandXAUTHORITY)

case ${COMMAND} in
	# Adjust this to your local system. Current config: xrandr --current
    "started") sudo -u ${USER} xrandr --output ${DISPLAY_SHARED_WITH_VM} --off ;;
    "stopped") sudo -u ${USER} xrandr --output ${DISPLAY_SHARED_WITH_VM} --right-of ${DISPLAY_HOST_DEDICATED} --auto ;; 
esac
