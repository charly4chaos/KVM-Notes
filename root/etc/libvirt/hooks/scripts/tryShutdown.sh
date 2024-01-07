#!/bin/sh
# Try to shutdown host on shutdown of vm
# Only takes vms in consideration which use the chaos:shutdown
DOMAIN=$1
COMMAND=$2

CONFIGFILE=/etc/libvirt/qemu/${DOMAIN}.xml

XPATH_NODE="/domain/metadata/*[name()='chaos:chaos']/*[name()='chaos:shutdown']"
XPATH_MODE="string(${XPATH_NODE}/@mode)"
XPATH_TIMEOUT="string(${XPATH_NODE}/@timeout)"

. $(dirname $0)/helper.sh

if ! [ ${COMMAND} = "stopped" ]; then
    exit 0
fi

# Check if tag is set for display-toggle
if ! xmllint --xpath "${XPATH_NODE}" ${CONFIGFILE} 1>/dev/null 2>/dev/null  ; then
	echo Ask for shutdown on vm stop not enabled for ${DOMAIN}.
	exit 0
fi

# Read configs
MODE=$(xmllint --xpath "${XPATH_MODE}" ${CONFIGFILE})
TIMEOUT=$(xmllint --xpath "${XPATH_TIMEOUT}" ${CONFIGFILE})
export DISPLAY=$(getXwaylandDisplay)
export USER=$(getXwaylandXUser)
export XAUTHORITY=$(getXwaylandXAUTHORITY)

case ${MODE:-ask} in
    "always") /usr/sbin/poweroff ;; 
    *) (
        sudo -u ${USER} zenity --question --text="Shutdown host? (${TIMEOUT:-60}s)" --timeout=${TIMEOUT:-60} --ok-label=Shutdown --cancel-label=Cancel
        case $? in 
            1) echo "Cancelled" ;; # Cancel
            0) /usr/sbin/poweroff ;; # Shutdown
            *) /usr/sbin/poweroff ;; # Timeout
        esac
    ) &
     ;;
esac
