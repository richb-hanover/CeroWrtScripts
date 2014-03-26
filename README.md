CeroWrtScripts
==============

The CeroWrt router firmware project has largely eliminated the problem of *bufferbloat*, which is a common reason that people complain, "the Internet feels slow today." The techniques that the CeroWrt team have proved out are being widely adopted across the Internet to make everyone's network performance better.

This is a set of scripts that we use to measure (and improve) latency in home routers (and everywhere else!) [http://bufferbloat.net/projects/cerowrt](http://bufferbloat.net/projects/cerowrt)

The first two scripts measure the performance of your router.

The second two scripts configure the CeroWrt router consistently after flashing factory firmware, and set up a IPv6 6-in-4 tunnel to TunnelBroker.net.

## betterspeedtest.sh

This script emulates the web-based test performed by speedtest.net, but does it one better. The script performs a download and an upload to a server on the Internet. The best part is that it simultaneously measures latency of pings to see whether the file transfers affect the latency. 

Here's why that's important: If the data transfers do increase the latency/lag much, then other network activity, such as voice or video chat, gaming, and general network activity will also work poorly. Gamers will see this as lagging out when someone else uses the network. Skype and FaceTime will see dropouts or freezes. Latency is bad, and good routers will not allow it to happen.

The betterspeedtest.sh script measures latency during file transfers. To invoke it:

    sh betterspeedtest.sh [ -H netperf-server ] [ -t duration ] [ -p host-to-ping ] 

Options, if present, are:

* -H | --host: DNS or Address of a netperf server (default - netperf.richb-hanover.com)
* -t | --time: Duration for how long each direction's test should run - (default - 60 seconds)
* -p | --ping: Host to ping to measure latency (default - gstatic.com)

The output shows the download or upload speed, along with a summary of latencies, including min, max, average, median, and 10th and 90th percentiles so you can get a sense of the distribution. The tool also displays the percent packet loss. An example below, showing two measurements. 

On the left is a test run without SQM. Note that the latency gets huge (greater than 5 seconds), meaning that network performance would be terrible for anyone else using the network. 

On the right is a test using SQM: the latency goes up a little (less than 23 msec under load), and network performance remains good.

    Example with NO SQM                                           Example using SQM
    
    root@cerowrt:/usr/lib/sqm# sh speedtest.sh                    root@cerowrt:/usr/lib/sqm# sh speedtest.sh
    Testing against netperf.richb-hanover.com while pinging       Testing against netperf.richb-hanover.com while pinging 
        gstatic.com (60 seconds in each direction)                    gstatic.com (60 seconds in each direction)
    
     Download:  6.19 Mbps                                         Download:  4.75 Mbps
      Latency: (in msec, 58 pings, 0.00% packet loss)              Latency: (in msec, 61 pings, 0.00% packet loss)
          Min: 43.399                                                  Min: 43.092
        10pct: 156.092                                               10pct: 43.916
       Median: 230.921                                              Median: 46.400
          Avg: 248.849                                                 Avg: 46.575
        90pct: 354.738                                               90pct: 48.514
          Max: 385.507                                                 Max: 56.150
    
       Upload:  0.72 Mbps                                           Upload:  0.61 Mbps
      Latency: (in msec, 59 pings, 0.00% packet loss)              Latency: (in msec, 53 pings, 0.00% packet loss)
          Min: 43.699                                                  Min: 43.394
        10pct: 352.521                                               10pct: 44.202
       Median: 4208.574                                             Median: 50.061
          Avg: 3587.534                                                Avg: 50.486
        90pct: 5163.901                                              90pct: 56.061
          Max: 5334.262                                                Max: 69.333
          
## netperfrunner.sh

Netperfrunner.sh is a shell script that runs several netperf commands simultaneously.
This mimics the stress test of netperf-wrapper from Toke <toke@toke.dk> 
but doesn't have the nice GUI result.
This can live in /usr/lib/sqm within CeroWrt.

When you start this script, it concurrently uploads and downloads four
streams (files) for 60 seconds to a server on the Internet. This places a heavy load 
on the bottleneck link of your network (probably your connection to the 
Internet), and lets you measure:

* total bandwidth available 
* latency, if you run a ping in a separate terminal window

To invoke the script:

    sh netperfrunner.sh [ netperf-server-to-test ]

where the optional *netperf-server-to-test* defaults to netperf.richb-hanover.com. The output of the script looks like this:

    Starting Network Performance tests. It will take about 60 seconds.
    It downloads four files, and concurrently uploads four files for maximum stress.
    For best effect, you should start a ping before starting this script
      to measure how much latency increases during the test. (It shouldn't
      increase much at all.)
    This test is part of the CeroWrt project. To learn more, visit:
      http://bufferbloat.net/projects/cerowrt/
    Download:  5.01 Mbps
      Upload:  0.36 Mbps

**Note:** The download and upload speeds reported may be considerably lower than your line's rated speed. This is not a bug, nor is it a problem with your internet connection. 

Here's what's going on: During these file transfers, the acknowledge messages sent back to the sender consume an interesting fraction of the link's capacity (as much as 25%). 
	 
## config-cerowrt.sh

This script updates the factory settings of CeroWrt to a known-good configuration.
If you frequently update your firmware, you can use this script to reconfigure
the router to a consistent state.
You should make a copy of this script, customize it to your needs,
then use the "To run this script" procedure (below).

This script is designed to configure the settings after an initial "factory" firmware flash. 
There are sections below to configure many aspects of your router.
All the sections are commented out. There are sections for:

- Set up the ge00/WAN interface to connect to your provider
- Update the software packages
- Update the root password
- Set the time zone
- Enable SNMP for traffic monitoring and measurements
- Enable NetFlow export for traffic analysis
- Enable mDNS/ZeroConf on the ge00 (WAN) interface 
- Change default IP addresses and subnets for interfaces
- Change default DNS names
- Set the SQM (Smart Queue Management) parameters
- Set the radio channels
- Set wireless SSID names
- Set the wireless security credentials

**To run this script**

Flash the router with factory firmware. Then ssh in and execute these statements. 
You should do this over a wired connection because some of these changes
may reset the wireless network.

    ssh root@172.30.42.1
    cd /tmp
    cat > config.sh 
    [paste in the contents of this file, then hit ^D]
    sh config.sh
    Presto! (You should reboot the router when this completes.)

**Note:** If you use a secondary CeroWrt router, you can create another copy of this script, and use it to set different configuration parameters (perhaps different subnets, radio channels, SSIDs, enable mDNS, etc).  

## tunnelbroker.sh

This script configures CeroWrt to create an IPv6 tunnel. 
It's an easy way to become familiar with IPv6 if your ISP doesn't offer native IPv6 capabilities. There are three steps:

1. Go to the Hurricane Electric [TunnelBroker.net](http://www.tunnelbroker.net/)  site to set up your free account. There are detailed instructions for setting up an account and an IPv6 tunnel at the
   [CeroWrt IPv6 Tunnel page.](http://www.bufferbloat.net/projects/cerowrt/wiki/IPv6_Tunnel) 
2. Edit the tunnelbroker.sh script, using the parameters supplied by Tunnelbroker.net. They're on the site's "Tunnel Details" page. Click on the "Example
Configurations" tab and select "OpenWRT Backfire 10.03.1". Use the info to fill in the corresponding lines of the script. 
3. ssh into the CeroWrt router and execute this script with these steps.
    
        ssh root@172.30.42.1
        cd /tmp
        cat > tunnel.sh 
        [paste in the contents of this file, then hit ^D]
        sh tunnel.sh
        [Restart your router. This seems to make a difference.]
  
Presto! Your tunnel is up! Your computer should get a global IPv6 address, and should be able to communicate directly with IPv6 devices on the Internet. To test it, try: `ping6 ivp6.google.com`
