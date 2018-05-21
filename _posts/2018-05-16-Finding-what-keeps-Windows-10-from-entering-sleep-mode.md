---
layout: post
title: "Finding what keeps Windows 10 from entering sleep mode"
date: 2018-05-16 21:46:36
categories: Windows PC
tags: PC
---

Few things annoy me as much as putting my laptop in my bag and heading off to whatever means of transportation I am using this day and hearing the laptop fans muffled promises of a flight with no power. This issue started happening quite frequently with my previously so superbly smooth running Surface Pro 4, and I wanted to find out why!

I messed around with Windows update, disabled power settings, enabled other settings and for a short while gave up, that is until I remembered the old Windows tool PowerCFG

PowerCFG (powercfg.exe) is a command-line utility that is used with admin rights to control **all** power system settings, including hardware-specific configurations that are not configurable through the Control Panel and since Windows 7 it has had some nifty commands to help with sleep mode and power issues.

The command **powercfg -REQUESTS** lists all application and driver requests that prevent the computer from automatically turning off the display or entering Sleep mode.

The command **powercfg -REQUESTSOVERRIDE** lets you override either individual availability requests or all availability requests.

When I first ran the requests command, I got the following output.

```
 PS C:\WINDOWS\system32> powercfg -REQUESTS

DISPLAY:
None.
SYSTEM:
[DRIVER] Realtek High Definition Audio(SST) (INTELAUDIO\FUNC_01&VEN_10EC&EV_0298&>SUBSYS_10EC108A&REV_1001\4&a4c0fcf&0&0001)
An audio stream is currently in use.

AWAYMODE:
None.

EXECUTION:
None.
```

This output could mean nothing, but it could also be our culprit! I rebooted my PC and found that the request was still there, hmm a faulty driver perhaps? Disabling the sound driver did solve my, and I started to look for an updated driver for my soundcard. After a short but unsuccessful hunt, I gave up and re-enabled the old drivers noticing that the request directly reappeared in the list after running **powercfg -REQUESTS** time to break out the big guns. 

>powercfg -REQUESTSOVERRIDE DRIVER "Realtek High Definition Audio(SST)" SYSTEM

I decided to add an override to the request, effectively forbidding the driver to keep my poor computer awake.

The command consists of three parts. The type of subsystem that is causing the issue (**DRIVER**), the name of the process (**Realtek High Definition Audio(SST)**) and what type of request we are overiding (**SYSTEM**). You can have three different types of requests the two most common being **DISPLAY** (that keeps your screen on) and **SYSTEM** (that keeps your computer from sleeping). To find the override commands you need to gather this information using the result of the  **powercfg -REQUESTS** command. 

Again running **powercfg -REQUESTSOVERRIDE** shows that I now have one active override and further testing shows that the problem is solved.

```
[SERVICE]

[PROCESS]

[DRIVER]
Realtek High Definition Audio(SST) SYSTEM      
```
A few days later I notice that I have severely lowered battery life despite solving the issue where my computer would refuse to sleep. Turns out while I was trying to solve the problem and trying different settings etcetera I accidentally switched over to the high-performance plan even when my computer was in battery-powered mode, funny thing it was **powercfg** that helped me figure that out too. 

To find out what is consuming energy on your computer you can use **powercfg -ENERGY** to generate a report with some possible issues your laptop could have with its power configuration.
 

![img]({{site.url}}/images/FWKW10FESM-1.png)

Losing power while idling in my bag was a huge annoyance to me, and I am ecstatic that it is no longer an issue and decided to write it down in case it could help someone else suffering from the laptop bags silent whisper of battery death. It's worth pointing out that even when someone have written a possibly faulty driver, Windows 10 offers the means and tools to find and fix the problem.  

If you wish to learn more about powercfg Scott Hanselman wrote a [post about powercfg](https://www.hanselman.com/blog/PowerCfgTheHiddenEnergyAndBatteryToolForWindowsYoureNotUsing.aspx) already in 2013 that is still well worth reading. And of course the [powercfg documentation](https://msdn.microsoft.com/en-us/library/dn898599(v=vs.85).aspx)
