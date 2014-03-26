#! /bin/sh
# Netperfrunner.sh - a shell script that runs several netperf commands simultaneously.
# This mimics the stress test of netperf-wrapper from Toke <toke@toke.dk> 
# but doesn't have the nice GUI result.
# This can live in /usr/lib/sqm within CeroWrt
# 
# When you start this script, it concurrently uploads and downloads multiple
# streams (files) to a server on the Internet. This places a heavy load 
# on the bottleneck link of your network(probably your connection to the 
# Internet), and lets you measure:
#
# a) total bandwidth available 
# b) latency, if you run a ping in a separate terminal window
# 
# Original version: 22 Feb 2014 - richb.hanover@gmail.com

# Create temp files for netperf up/download results
ULFILE=`mktemp /tmp/netperfUL.XXXXXX` || exit 1
DLFILE=`mktemp /tmp/netperfDL.XXXXXX` || exit 1

# Default values for test duration and netperf server host
TESTDUR="60"
TESTHOST="netperf.richb-hanover.com"

echo "Starting Network Performance tests. It will take about $TESTDUR seconds."
echo "It downloads four files, and concurrently uploads four files for maximum stress."
echo "For best effect, you should start a ping before starting this script"
echo "  to measure how much latency increases during the test. (It shouldn't"
echo "  increase much at all.)"
echo "This test is part of the CeroWrt project. To learn more, visit:"
echo "  http://bufferbloat.net/projects/cerowrt/"

# send data from netperf client to the netperf server
# netperf writes the sole output value (in Mbps) to stdout when completed
{ netperf -H $TESTHOST -t TCP_STREAM -l $TESTDUR -v 0 -P 0 >> $ULFILE; } &
{ netperf -H $TESTHOST -t TCP_STREAM -l $TESTDUR -v 0 -P 0 >> $ULFILE; } &
{ netperf -H $TESTHOST -t TCP_STREAM -l $TESTDUR -v 0 -P 0 >> $ULFILE; } &
{ netperf -H $TESTHOST -t TCP_STREAM -l $TESTDUR -v 0 -P 0 >> $ULFILE; } &

# send data from netperf server to the client
{ netperf -H $TESTHOST -t TCP_MAERTS -l $TESTDUR -v 0 -P 0 >> $DLFILE; } &
{ netperf -H $TESTHOST -t TCP_MAERTS -l $TESTDUR -v 0 -P 0 >> $DLFILE; } &
{ netperf -H $TESTHOST -t TCP_MAERTS -l $TESTDUR -v 0 -P 0 >> $DLFILE; } &
{ netperf -H $TESTHOST -t TCP_MAERTS -l $TESTDUR -v 0 -P 0 >> $DLFILE; } &

# wait until all the background tasks finish
wait
# cat $DLFILE
# cat $ULFILE

# sum up all the values (one line per netperf test) from $DLFILE and $ULFILE
echo "Download: " `awk '{s+=$1} END {print s}' $DLFILE` Mbps
echo "  Upload: " `awk '{s+=$1} END {print s}' $ULFILE` Mbps
