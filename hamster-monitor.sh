#!/usr/bin/env bash

# Script used by i3status-rs to monitor current Hamster status
#
set -eo pipefail
#set -x


update_pid=

function clean_up_background() {
   [ -n "$update_pid" ] && kill -9 "$update_pid" || true
}
trap clean_up_background EXIT HUP INT QUIT ABRT BUS PIPE TERM 

function send_current_activity() 
{
   activity=$(hamster current | sed -e "s|^[^ ]\+ [^ ]\+ \([^,]*\)\(,.*\)\? \(.*\)$|\1 \3|" -e "s/  Aucune.*//")
   short_activity="$activity"
   if [[ "${#activity}" -ge 15 ]]
   then
      short_activity="$(echo "$activity" | awk '{$(NF--)=""; print}' | cut -c 1-9)…$(echo "$activity" | awk '{ print $NF}')"
   fi
   qdbus rs.i3status /CurrentHamsterActivity rs.i3status.custom.SetText "$activity" "$short_activity"
   qdbus rs.i3status /CurrentHamsterActivity rs.i3status.custom.SetState info
   echo "$activity"
}

function update() {
   #set -x
   activity="${1% *}"
   done="${1##* }"
   minutes=1
   while true 
   do
      sleep 60
      elapsed=$(date +%H:%M -d "$done today + $minutes minute")
      short_activity="$activity"
      if [[ "${#activity}" -ge 9 ]]
      then
	 short_activity="$(echo "$activity" | cut -c 1-9)…"
      fi
      qdbus rs.i3status /CurrentHamsterActivity rs.i3status.custom.SetText "$activity $elapsed" "$short_activity $elapsed"
      minutes=$((minutes + 1))
   done
}


function update_i3 () 
{
   clean_up_background
   activity=$(send_current_activity)
   update "$activity" & #> /tmp/rofi_hamster.log 2>&1 & 
   update_pid="$!"
}

sleep 2
update_i3 2> /dev/null

dbus-monitor --profile interface=org.gnome.Hamster,member=AddFactJSON interface=org.gnome.Hamster,member=StopTracking | \
   while read -r line
   do
      update_i3 2>/dev/null
   done
