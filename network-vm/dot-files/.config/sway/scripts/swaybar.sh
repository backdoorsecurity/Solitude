#!/bin/bash
while
TIME="$(date +"%m/%d %I:%M")"

printf `"[""td":`%s`"]` \
"[""$TIME""]                                           " 2>/dev/null

do sleep 60;
done
