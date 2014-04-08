#!/bin/sh

# betterspeedtest.sh - Script to simulate http://speedtest.net
# Start pinging, then initiate a 60 second download, then a 60 second upload
# Output the measured transfer rate and the resulting ping latency
# It's better because it measures latency while measuring the speed.

# Usage: sh betterspeedtest.sh [ -H netperf-server ] [ -t duration ] [ -t host-to-ping ]

# Options: If options are present:
#
# -H | --host: DNS or Address of a netperf server (default - netperf.richb-hanover.com)
# -t | --time: Duration for how long each direction's test should run - (default - 60 seconds)
# -p | --ping: Host to ping to measure latency (default - gstatic.com)

# Copyright (c) 2014 - Rich Brown
# GPLv2

# Summarize the contents of the ping's output file to show min, avg, median, max, etc.
# 	input parameter ($1) file contains the output of the ping command

summarize_pings() {			
	
	# Process the ping times, and summarize the results
	# grep to keep lines that have "time=", then sed to isolate the time stamps, and sort them
	# awk builds an array of those values, and prints first & last (which are min, max) 
	#	and computes average.
	# If the number of samples is >= 10, also computes median, and 10th and 90th percentile readings
	sed 's/^.*time=\([^ ]*\) ms/\1/' < $1 | grep -v "PING" | sort -n | \
	awk 'BEGIN {numdrops=0; numrows=0;} \
		{ \
			if ( $0 ~ /timeout/ ) { \
			   	numdrops += 1; \
			} else { \
				numrows += 1; \
				arr[numrows]=$1; sum+=$1; \
			} \
		} \
		END { \
			pc10="-"; pc90="-"; med="-"; \
			if (numrows == 0) {numrows=1} \
			if (numrows>=10) \
			{ 	ix=int(numrows/10); pc10=arr[ix]; ix=int(numrows*9/10);pc90=arr[ix]; \
				if (numrows%2==1) med=arr[(numrows+1)/2]; else med=(arr[numrows/2]); \
			}; \
			pktloss = numdrops/(numdrops+numrows) * 100; \
			printf("  Latency: (in msec, %d pings, %4.2f%% packet loss)\n      Min: %4.3f \n    10pct: %4.3f \n   Median: %4.3f \n      Avg: %4.3f \n    90pct: %4.3f \n      Max: %4.3f\n", numrows, pktloss, arr[1], pc10, med, sum/numrows, pc90, arr[numrows] )\
		 }'
}

# Print a line of dots as a progress indicator.

print_dots() {
	while : ; do
		printf "."
		sleep 1s
	done
}

# Stop the current print_dots() process

kill_dots() {
	# echo "Pings: $ping_pid Dots: $dots_pid"
	kill -9 $dots_pid
	wait $dots_pid 2>/dev/null
	dots_pid=0
}

# Stop the current ping process

kill_pings() {
	# echo "Pings: $ping_pid Dots: $dots_pid"
	kill -9 $ping_pid 
	wait $ping_pid 2>/dev/null
	ping_pid=0
}

# Stop the current pings and dots, and exit
# ping command catches (and handles) first Ctrl-C, so you have to hit it again...
kill_pings_and_dots_and_exit() {
	kill_dots
	echo "\nStopped"
	exit 1
}

# ------------ Measure speed and ping latency for one direction ----------------
#
# Called with measure_direction "Download" $TESTHOST $TESTDUR $PINGHOST

measure_direction() {

	# Create temp files
	PINGFILE=`mktemp /tmp/measurepings.XXXXXX` || exit 1
	SPEEDFILE=`mktemp /tmp/netperfUL.XXXXXX` || exit 1
	
	# Start dots
	print_dots &
	dots_pid=$!
	# echo "Dots PID: $dots_pid"

	# Start Ping
	ping $4 > $PINGFILE &
	ping_pid=$!
	# echo "Ping PID: $ping_pid"
	
	# Start netperf with the proper direction
	if [ $1 == "Download" ]; then
		dir="TCP_MAERTS"
	else
		dir="TCP_STREAM"
	fi
	# netperf -H HOST-TO-TEST -t DIRECTION -l DURATION ...
	netperf -H $2 -t $dir -l $3 -v 0 -P 0 >> $SPEEDFILE

	# Print TCP Download speed
	echo ""
	echo " $1: " `awk '{s+=$1} END {print s}' $SPEEDFILE` Mbps

	# When netperf completes, stop the dots and the pings
	kill_pings
	kill_dots

	# Summarize the ping data
	summarize_pings $PINGFILE

	rm $PINGFILE
	rm $SPEEDFILE
}

# ------- Start of the main routine --------

# Usage: sh betterspeedtest.sh [ -H netperf-server ] [ -t duration ] [ -p host-to-ping ]

# “H” and “host” DNS or IP address of the netperf server host (default: netperf.richb-hanover.com)
# “t” and “time” Time to run the test in each direction (default: 60 seconds)
# “p” and “ping” Host to ping for latency measurements (default: gstatic.com)

# set an initial values for defaults
TESTHOST="netperf.richb-hanover.com"
TESTDUR="60"
PINGHOST="gstatic.com"

# read the options

# extract options and their arguments into variables.
while [ $# -gt 0 ] 
do
    case "$1" in
        -H|--host)
            case "$2" in
                "") echo "Missing hostname" ; exit 1 ;;
                *) TESTHOST=$2 ; shift 2 ;;
            esac ;;
        -t|--time) 
        	case "$2" in
        		"") echo "Missing duration" ; exit 1 ;;
                *) TESTDUR=$2 ; shift 2 ;;
            esac ;;
        -p|--ping)
            case "$2" in
                "") echo "Missing ping host" ; exit 1 ;;
                *) PINGHOST=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Usage: sh betterspeedtest.sh [ -H netperf-server ] [ -t duration ] [ -p host-to-ping ]" ; exit 1 ;;
    esac
done

# Start the main test

DATE=`date "+%Y-%m-%d %H:%M:%S"`
echo "$DATE Testing against $TESTHOST while pinging $PINGHOST ($TESTDUR seconds in each direction)"

# Catch a Ctl-C and stop the pinging and the print_dots
trap kill_pings_and_dots_and_exit SIGHUP SIGINT SIGTERM

measure_direction "Download" $TESTHOST $TESTDUR $PINGHOST
measure_direction "  Upload" $TESTHOST $TESTDUR $PINGHOST
