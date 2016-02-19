//
//  AppDelegate.h
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kNotificationReady @"kNotificationReady"
#define kNotificationTagFound @"kNotificationTagFound"
#define kNotificationTagLost @"kNotificationTagLost"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CBCentralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectedShield;

@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CBPeripheral *peripheral;

- (void)sendMessage:(NSString *)message;
- (void) restartMonitoring;

@end
