High Level Interface (HLI)
==========================

The HLI is another computer on AAUSHIP that is providing the intelligent
interfacer for the ship, in other words it is the main brain, while the LLI
is just an universal interface that is ship hardware dependent.

It is written in python for the ease of use.

Source files and other files
----------------------------
`42-aauship.rules` is udev rules that ensures that consitent device
names is assigned for the USB devides such as the second GPS,
echosounder, LLI, and radio interface. It is to be copied into
`/etc/udev/rules.d`. (The radio interface is used on the GRS to
communicate with the LLI directly, not on the ship.)

In the `python` dir
-------------------
`lli-tester.py` is a script to run standalone to show some info from
the LLI and that it works.

`packetparser.py`

`packetHandler.py`

`gpsfunctions.py`

In the `ros` dir
----------------
This is the ROS.org system than runs on the ships.

# ROS setup
Remember to add the soruces to your shell i.e.

    source /opt/ros/hydro/setup.bash                                                
    source ~/aauship-formation/code/hli/ros/devel/setup.bash 

Install pynmea with `pip install pynmea`

Connectivity
------------
Connect initially to wireless network with nm
nmcli dev wifi connect <name> password <password>

Connect to a network profile already set up
nmcli con up id <idofprofile>
