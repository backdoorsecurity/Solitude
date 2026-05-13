#!/bin/bash
while
TIME="$(date +"%m/%d %I:%M")"
BATTERY=$(cat /sys/class/power_supply/BAT0/capacity)
WATTAGE=$(awk '{printf "%.1f", $1 / 1000000}' /sys/class/power_supply/BAT0/power_now)
CPUTEMP=$(cut -c1-2 /sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input)
GPUTEMP=$(cut -c1-2 /sys/class/hwmon/hwmon5/temp2_input)
CPUFRQ=$(awk '{printf "%.1f", $1 / 1000000}' /sys/bus/cpu/devices/cpu0/cpufreq/scaling_cur_freq)
GPUFRQ=$(awk '{printf "%.1f", $1 / 100}' /sys/class/drm/card0/gt_cur_freq_mhz)

printf `"[""td":`%s`"][""gpufreq":`%s`"][""gputemp":`%s`"][""cputemp":`%s`"][""cpufrq":`%s`"][""bat":`%s`"][""wat":%s"]"` \
"[""$TIME""] [GPU:""$GPUFRQ"GHZ"@""$GPUTEMP"*c"][CPU:""$CPUFRQ"GHZ"@""$CPUTEMP"*c"][""$BATTERY"%"|""$WATTAGE"W"]" 2>/dev/null

#printf '[CPU: %s GHz %s°C][BAT: %s%%  %sW]' \
#"$COLOR" "$CPUFRQ" "$CPUTEMP" "$BATTERY" "$WATTAGE"

#printf 'CPU: %s GHz  %s°C [BAT: %s%%  %sW\n' \
#    "$CPUFRQ" "$CPUTEMP" "$BATTERY" "$WATTAGE" >&2;
do sleep 5;
done
