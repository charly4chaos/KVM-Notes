#!/bin/sh

getEnvironVariableFromProcess() 
{
    cat /proc/$( ps -C $1 --no-headers -o pid | tr -d ' ' )/environ | tr '\0' '\n' | grep -E "^$2=.*$" | sed 's/.*=//g'
}

# This functions works only if there is only one running display session !
getXwaylandDisplay()
{
    getEnvironVariableFromProcess Xwayland DISPLAY
}

# This functions works only if there is only one running display session !
getXwaylandXUser()
{
    getEnvironVariableFromProcess Xwayland USER
}

# This functions works only if there is only one running display session !
getXwaylandXAUTHORITY()
{
    getEnvironVariableFromProcess Xwayland XAUTHORITY
}
