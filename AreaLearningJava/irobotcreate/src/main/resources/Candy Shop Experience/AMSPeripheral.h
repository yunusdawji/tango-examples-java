//
//  AMSPeripheral.h
//  AirMilesStore
//
//  Created by Jeffrey Deng on 2014-05-29.
//  Copyright (c) 2014 Jeffrey Deng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AMSPeripheral : NSObject

@property (retain, nonatomic) NSNumber *RSSI;
@property (retain, nonatomic) CBPeripheral *peripheral;

@end
