#!/bin/bash
if [ $# -eq 0 ]; then
    echo >&2 "Usage: jstackSeries <pid>[ <count> [ ,<delay> [, <logpath> ] ] ]"
    echo >&2 "    Defaults: count = 10 (0 means infinite), delay = 0 (seconds), logpath = ./logs"
    exit 1
fi

pid=$1          # required
count=${2:-10}  # defaults to 10 times, if - means infinite
delay=${3:-10}  # defaults to 10 seconds
logpath=${4-./logs}

infinite=0

if [ $2 -eq 0 ]; then
	infinite=1
	count=10
fi

echo "config: delay=3; infinite=$infinite; logpath=$logpath"

mkdir -p $logpath

while [ $count -gt 0 ]
do
    jstack -l $pid > $logpath/jstack.$pid.$(date +%H%M%S.%N).log
    sleep $delay
	
	if [ $infinite -eq 0 ]; then
		let count--
	fi
	
    echo -n "."
done