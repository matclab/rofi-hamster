#!/usr/bin/env bash

# Script used by i3status-rs to monitor current Hamster status
#
set -eo pipefail


update_pid=

function clean_up_background() {
   [ -n "$update_pid" ] && kill -9 "$update_pid"; true
}
trap clean_up_background EXIT HUP INT QUIT ABRT BUS PIPE TERM 

function send_current_activity() 
{
   activity=$(hamster current | sed -e "s|^[^ ]\+ [^ ]\+ \([^,]*\)\(,,.*\)\? \(.*\)$|\1 \3|" -e "s/  Aucune.*//")
   qdbus i3.status.rs /CurrentHamsterActivity i3.status.rs.SetStatus "$activity" " " Info
   echo "$activity"
}

function update() {
   activity="${1% *}"
   done="${1##* }"
   minutes=1
   while true 
   do
      sleep 60
      elapsed=$(date +%H:%M -d "$done today + $minutes minute")
      qdbus i3.status.rs /CurrentHamsterActivity i3.status.rs.SetStatus "$activity $elapsed" " " Info
      minutes=$((minutes + 1))
   done
}


function update_i3 () 
{
   clean_up_background
   activity=$(send_current_activity)
   update "$activity" & 
   update_pid="$!"
}

sleep 2
update_i3 2> /dev/null

dbus-monitor --profile interface=org.gnome.Hamster,member=AddFactJSON interface=org.gnome.Hamster,member=StopTracking | \
   while read -r line
   do
      update_i3 2>/dev/null
   done
