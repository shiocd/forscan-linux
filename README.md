![image](https://github.com/shiocd/forscan-linux/assets/664928/f0c852db-7fff-4851-9b60-4f1c3daf8b57)

### WHAT IS THIS THING ?
A way to run the 32-bit forscan windows software (forscan.org) in x86-64 linux env.


### BUT WHY ?!?
I don't own any windows computers and I don't want to get one for running forscan.

Forscan itself works great with wine.

However, there are often annoying amount of problems in many distros with installing and running wine32 environment. Also, you might want some isolation because wine32 pulls in tens of i386 libraries.

Docker to the rescue!


### Prerequisites

0) I'm using OBDLink EX adapter, anyhing else might not work at all
1) make sure your user is member of the dialout group, for OBD adapter access
2) plug in the OBD adapter, check that it shows up in dmesg/lsusb/dev (as /dev/ttyUSB0)
3) install docker and ensure your user can run docker, user has to be member of the docker group
4) if you need to override the OBD device, you can do it via ENV like so:
   `DEV=/dev/ttyACM0 make ...`


### Installation
To run these commands, you need gnu make OS package.

**`make build`**
 * builds the base ubuntu 22.04 wine32 image
 * it takes a while depending on network speed etc
 * in the end you should see output:
   `Successfully tagged forscan:latest`

**`make init`**
 * download and install forscan_setup.exe
 * run forscan for first time
 * make all necessary configuration changes you want within the program:
   * configure connection type as COM and comms port as COM1
   * disable demo mode
   * suppress nag dialogs
   * insert activation key if needed
   * test that OBD connection works
 * when happy with all changes, close the program
 * all changes made will be saved

**`make winecfg`**
 * if you want to change font size or other wine settings


### Daily usage
**`make run`**
 * run forscan
 * the *shared* directory is accessible inside container as /home/forscan/FORScan
 * use the directory for storing profiles, logs, license key etc

Everything else in the container is not saved between runs!

**`make update`**
 * fetch latest forscan release and update image

**`make config`**
 * run this if you ever need to make configuration changes that persist between runs

**`make clean build init`**
 * if you mess something up and want to start fresh


### Notes
The docker process will download approx 200 MB of stuff.
Final docker image size is around 1.5 GB.


### Demo images
![image](https://github.com/shiocd/forscan-linux/assets/664928/19396343-49fe-4201-9335-f5755f2d028a "Access vehicle, module list")
![image](https://github.com/shiocd/forscan-linux/assets/664928/c5662fd0-2bbe-41df-9b7d-70011b8e31ee "DTC list")


## DISCLAIMER
* No warranty, no support, no nothing.
* It works for me, it might work for you.
* Feel free to fork and send pull requests for any improvement.

**IF ANYTHING BREAKS, YOU GET TO KEEP BOTH PIECES.**

