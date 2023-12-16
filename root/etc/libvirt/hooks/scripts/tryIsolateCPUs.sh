#!/bin/bash
# Try to isolate pinned cpus
# Only takes vms in consideration which use the chaos:cpu-isolation
DOMAIN=$1

XPATH_ISOLATION="/domain/metadata/*['chaos:chaos']/*['chaos:cpu-isolation']"
XPATH_ISOLATION_GOVERNOR="string(${XPATH_ISOLATION}/@set-governor)"

# Check if tag is set for cpu-isolation
if ! xmllint --xpath "${XPATH_ISOLATION}" /etc/libvirt/qemu/${DOMAIN}.xml 1>/dev/null 2>/dev/null ; then
	echo CPU isolation not enabled for ${DOMAIN}.
	exit 0
fi

# Collect avaiable cpus and pinned cpus of upcoming and running vms
# Does only handle single CPUs, comma seperated ("5,6,7") or short ranges ("1-2"). Longer ranges ("1-9") are not supported.
AVAILABLE_CPUS=($(lscpu -ap=cpu | grep -v '#'))
VMS_TO_CHECK=($(echo $(find /run/systemd/machines/ -name 'qemu-*' | sed -E 's/.*qemu-[0-9]-//g' | tr '\n' ' ')))
PINNED_CPUS=($(for domain in ${VMS_TO_CHECK[@]};
    do
        if xmllint --xpath "${XPATH_ISOLATION}" /etc/libvirt/qemu/${DOMAIN}.xml 1>/dev/null 2>/dev/null ; then
            xmllint --xpath '//*[@cpuset]/@cpuset' /etc/libvirt/qemu/${domain}.xml 
        fi
    done | grep -oE '[0-9]+' | sort -n | uniq | tr '\n' ' ' | sed 's/.$//')
)

# Prepare list to limit host to
export INDEX_PINNED_CPUS=0
export INDEX_AVAILABLE_CPUS=0
while [ ${INDEX_PINNED_CPUS} -lt ${#PINNED_CPUS[@]} ]
do
    if [ ${PINNED_CPUS[$INDEX_PINNED_CPUS]} -eq ${AVAILABLE_CPUS[$INDEX_AVAILABLE_CPUS]} ]; then
        AVAILABLE_CPUS[$INDEX_AVAILABLE_CPUS]=""
        export INDEX_PINNED_CPUS=$(($INDEX_PINNED_CPUS+1))
        export INDEX_AVAILABLE_CPUS=$(($INDEX_AVAILABLE_CPUS+1))
    elif [ ${PINNED_CPUS[$INDEX_PINNED_CPUS]} -lt ${AVAILABLE_CPUS[$INDEX_AVAILABLE_CPUS]} ]; then
        export INDEX_PINNED_CPUS=$(($INDEX_PINNED_CPUS+1))
    else 
        export INDEX_AVAILABLE_CPUS=$(($INDEX_AVAILABLE_CPUS+1))
    fi
done

# Try set list of cpus
AVAILABLE_CPUS_PARAM=$(echo ${AVAILABLE_CPUS[@]} | tr ' ' ',')
if [ ${#AVAILABLE_CPUS_PARAM} -eq 0 ];then
    echo "No allowed cpus left, skip setting!"
else
    echo Pinned cpus = ${PINNED_CPUS[@]}
    echo Allowed cpus for host = ${AVAILABLE_CPUS_PARAM}

    # Set list of cpus
    systemctl set-property --runtime -- user.slice AllowedCPUs=${AVAILABLE_CPUS_PARAM}
    systemctl set-property --runtime -- system.slice AllowedCPUs=${AVAILABLE_CPUS_PARAM}
    systemctl set-property --runtime -- init.scope AllowedCPUs=${AVAILABLE_CPUS_PARAM}
fi

if [ "$(xmllint --xpath "${XPATH_ISOLATION_GOVERNOR}" /etc/libvirt/qemu/${DOMAIN}.xml 2>/dev/null)" = "yes" ] ; then
    echo "Try set cpu scaling governor"
    # Force performance mode on pinned cpu
    for PINNED_CPU in ${PINNED_CPUS[@]}
    do 
        echo performance > /sys/devices/system/cpu/cpu${PINNED_CPU}/cpufreq/scaling_governor
    done

    # Reset available cores to powersave when any cpu uses powersave mode
    if  grep "powersave" /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor &>/dev/null; then
        for AVAILABLE_CPU in ${AVAILABLE_CPUS[@]}
        do 
            echo powersave > /sys/devices/system/cpu/cpu${AVAILABLE_CPU}/cpufreq/scaling_governor
        done
    fi
fi