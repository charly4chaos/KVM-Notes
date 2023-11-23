#!/bin/bash
# Expects user to have the permission to run /usr/sbin/poweroff
export VMNAME=${1:-none}

virsh domstate ${VMNAME} 1>/dev/null || exit 1

if [[ $(virsh domstate ${VMNAME}) == "shut off" ]]; then
  echo "# Start ${VMNAME}"
  virsh start ${VMNAME} 1>/dev/null || exit 1
  sleep 5
fi

echo "# Wait for ${VMNAME} to finish"
until [[ $(virsh domstate ${VMNAME}) == "shut off" ]];
do 
  sleep 10
done

echo
read -t 60 -p "Peform host shutdown? [Y/n] (60s) " userInput
if [[ ${userInput:-y} == "y" ]] || [[ ${userInput:-y} == "Y" ]]; then
  /usr/sbin/poweroff
else
  echo Skipped shutdown
fi