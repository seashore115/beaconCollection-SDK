//
//  BeaconsCollection.h
//  iOS-SDK-BeaconsCollection
//
//  Created by Apple on 14-4-6.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeaconManager.h"
extern NSString *majorAndMinor;
@interface BeaconsCollection : NSObject<ESTBeaconManagerDelegate>{
    ESTBeaconManager* beaconManager;
    NSString*         majorAndMinor;
    NSString*         distance;
}
@property(copy, nonatomic) NSString* floorPlanId;
@property(copy, nonatomic) NSString* roomName;
@property(nonatomic,strong) ESTBeaconManager* beaconManager;
@property(copy, nonatomic) NSArray* beaconArray;
@property(strong,nonatomic)NSString* distance;
@property(strong,nonatomic)NSString* majorAndMinor;
@property(nonatomic) NSInteger count;
@property(strong, nonatomic)ESTBeacon* indexString;

-(void)beaconStart;
// this function is used to post message: floorPlanId refers to floorplan id; room refers to which room u decides to record; count refers to the sum of rooms in current floorplan id.
-(void)postMessage:(NSString *)floorPlanId room:(NSString *)roomName count:(NSInteger)count majorAndMinor:(NSString *) majorMinor distance: (NSString *)distanceString;
// this function is used to obtain current room name 
-(NSString *)getCurrentRoom:(NSString *)floorPlanId majorAndMinor:(NSString*) majorMinor;

@end
