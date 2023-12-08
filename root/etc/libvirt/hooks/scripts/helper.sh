#!/bin/sh

# This functions works only if there is only one running display session !
getRunningDisplay()
{
    w -h -s | grep -Eo ':[[:digit:]]+' | head -n 1
}

# This functions works only if there is only one running display session !
getRunningXUser()
{
    ps ho user $(pgrep X)
}