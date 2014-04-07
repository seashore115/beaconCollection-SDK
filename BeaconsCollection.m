//
//  BeaconsCollection.m
//  iOS-SDK-BeaconsCollection
//
//  Created by Apple on 14-4-6.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "BeaconsCollection.h"


@implementation BeaconsCollection
@synthesize beaconManager=_beaconManager;
@synthesize floorPlanId=_floorPlanId;
@synthesize roomName=_roomName;
@synthesize count=_count;
@synthesize beaconArray;
@synthesize distance=_distance;
@synthesize majorAndMinor=_majorAndMinor;
@synthesize indexString;

-(void)beaconStart{

        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        self.beaconManager.avoidUnknownStateBeacons = YES;

        // create sample region object (you can additionaly pass major / minor values)
        ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                     identifier:@"EstimoteSampleRegion"];
        
        // start looking for estimote beacons in region
        // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
        [self.beaconManager startRangingBeaconsInRegion:region];

}


-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region{
    if ([beacons count]>0) {
        beaconArray=beacons;
        indexString=[beacons objectAtIndex:0];
        self.majorAndMinor= [NSString stringWithFormat:
                               @"Major: %i, Minor: %i",
                               [indexString.major unsignedShortValue],
                               [indexString.minor unsignedShortValue]];
        float rawDistance=[indexString.distance floatValue];
        self.distance= [NSString stringWithFormat:@"%.3f",rawDistance];
    }
}

-(void)postMessage:(NSString *)floorPlanId room:(NSString *)roomName count:(NSInteger)count majorAndMinor:(NSString *) majorMinor distance: (NSString *)distanceString {

    NSString *subUrl=@"http://1.mccnav.appspot.com/mcc/beacons/";
    NSString *url=[subUrl stringByAppendingString:floorPlanId];
    NSURL *dataUrl=[[NSURL alloc] initWithString:url];
    NSMutableDictionary *mDict=[NSMutableDictionary dictionaryWithCapacity:4];
    NSString *id=[[floorPlanId stringByAppendingString:@"."]stringByAppendingString:roomName];
    [mDict setObject:floorPlanId forKey:@"floorplanId"];
    [mDict setObject:roomName forKey:@"locationId"];
    [mDict setObject:id forKey:@"id"];
    NSLog(@"%@",majorMinor);
    NSMutableDictionary *subDict=[NSMutableDictionary dictionaryWithCapacity:2];
    NSString *identityId=[@"identityId:" stringByAppendingString:majorMinor];
    [subDict setObject:identityId forKey:@"beaconId"];
    [subDict setObject:distanceString forKey:@"distance"];
    NSArray *subArray=[NSArray arrayWithObjects:subDict,nil];
    [mDict setObject:subArray forKey:@"beaconIds"];
    //GET
    NSMutableArray *sendData=[[NSMutableArray alloc]initWithCapacity:count];
    NSData *allLocationData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    NSError *error;
    NSArray *allLocation = [NSJSONSerialization
                            JSONObjectWithData:allLocationData
                            options:kNilOptions
                            error:&error];
    if( error )
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        NSDictionary *location;
        for ( location in allLocation )
        {
            if ([roomName isEqualToString:[location objectForKey:@"locationId"]])
                location=mDict;
            [sendData addObject:location];
        }
        NSLog(@"%@",[sendData description]);
    }
    
    //json
    if ([NSJSONSerialization isValidJSONObject:sendData]) {
        NSError *error;
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:sendData options:NSJSONReadingMutableContainers |NSJSONReadingAllowFragments error:&error];
        NSString *json=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *reqData=[@"beaconsMapping=" stringByAppendingString:json];
        NSData *postDatas=[reqData dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength=[NSString stringWithFormat:@"%lu",(unsigned long)[postDatas length]];
        NSMutableURLRequest *requestPost=[NSMutableURLRequest requestWithURL:dataUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        [requestPost setHTTPMethod:@"POST"];
        [requestPost setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [requestPost setHTTPBody:postDatas];
        
        NSError *requestError=nil;
        NSURLResponse *response = nil;
        NSData *data=[NSURLConnection sendSynchronousRequest:requestPost returningResponse:&response error:&requestError];
        if (requestError == nil) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200) {
                    NSLog(@"Warning, status code of response was not 200, it was %ld", (long)statusCode);
                }
            }
            
            NSError *error;
            NSDictionary *returnDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (returnDictionary) {
                NSLog(@"returnDictionary=%@", returnDictionary);
            } else {
                NSLog(@"error parsing JSON response: %@", error);
                
                NSString *returnString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                NSLog(@"returnString: %@", returnString);
            }
        } else {
            NSLog(@"NSURLConnection sendSynchronousRequest error: %@", requestError);
        }
        
        
    }

    

}

-(NSString *)getCurrentRoom:(NSString *)floorPlanId majorAndMinor:(NSString*) majorMinor {
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];
    
    [self.beaconManager startRangingBeaconsInRegion:region];
    NSString *subUrl=@"http://1.mccnav.appspot.com/mcc/beacons/";
    NSString *url=[subUrl stringByAppendingString:floorPlanId];
    NSData *allLocationData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    NSError *error;
    NSArray *allLocation = [NSJSONSerialization
                            JSONObjectWithData:allLocationData
                            options:kNilOptions
                            error:&error];
    NSString* matchMajor;
    if( error )
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        NSDictionary *location;
        for ( location in allLocation )
        {
            NSArray *beaconIds=[location objectForKey:@"beaconIds"];
            NSDictionary *dict;
            for (dict in beaconIds) {
                NSString *string= [dict objectForKey:@"beaconId"];
                if ([string rangeOfString:majorMinor].location!=NSNotFound) {
                    matchMajor=[location objectForKey:@"locationId"];
                }
            }
            
            
        }
    }
    return matchMajor;
}





@end
