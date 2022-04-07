#!/bin/bash
# This script is checking the battery level for my msi laptop (ubuntu 18.04 LTS)
# requirements
# - acpi (sudo apt install acpi)
# - icon was found with `find /usr/share/icons/ -iname "*batt*low*"` command
battery_to_check='Battery 1'
warn_limit=7
battery_level=$(acpi -b | grep "${battery_to_check}" | grep -P -o '[0-9]+(?=%)')
icon='/usr/share/icons/Humanity/status/48/battery-low.svg'
status=$(cat /sys/class/power_supply/BAT1/status)
if [ $battery_level -le $warn_limit ] && [ $status = 'Discharging' ]; then
    notify-send -u critical -i $icon "Battery low" "Battery level is ${battery_level}%!"
fi
