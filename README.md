beaconCollection-SDK
====================

This is a beacon collection sdk, which is used to track, post, fetch beacons messages.

configurations:

import all the files and add systemConfiguration.framework into your libaray.

import ESTBeaconManager.h and beaconCollection.h into .h file.

add ESTBeaconManagerDelegate delegate protocol

run it:

copy content of startbeacon function to your viewDidLoad function

add beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region totally into your .m file

initilize beaconcollection class and call functions defined in the beaconcollection.m except startbeacon and beaconManager.

