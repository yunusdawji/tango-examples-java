//
//  AppDelegate.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "BLEShieldDataPacket.h"
#import "BLEUtility.h"
#import "AMSConnectionManager.h"



@implementation AppDelegate{
    CLLocationManager *_locationManager;
    CLBeaconRegion *_regionToMonitor;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [MagicalRecord setupCoreDataStack];
    
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Scanning..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = CGPointMake(floor(WIDTH(self.alertView) / 2), floor(HEIGHT(self.alertView) / 2) - 5);
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [activityIndicator startAnimating];
    [self.alertView addSubview:activityIndicator];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.peripherals = [NSMutableArray array];
    
    NSDictionary *appDefaults = @{@"email": @NO, @"probability": @0.2, @"ble": @NO, @"rssi": @-50, @"wifi": @NO, @"server": @"http://192.168.0.70:8888", @"soldout": @"", @"eventmode" :@NO, @"serveraddress" : @"http://10.0.1.13:8888/", @"orderserveraddress": @"http://10.0.1.20:9000/"} ;
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    UIImage *gradientImage44 = [[UIImage imageNamed:@"navigation-bar"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44
                                      forBarMetrics:UIBarMetricsDefault];
    
   // [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithHue:339.0f/360.0f saturation:0.86f brightness:0.83f alpha:1.0f]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //set location manager
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    _regionToMonitor = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BROADCAST_UUID] identifier:REGION_ID];
    [_regionToMonitor setNotifyEntryStateOnDisplay:YES];
    [_regionToMonitor setNotifyOnEntry:YES];
    [_regionToMonitor setNotifyOnExit:YES];
    
    //[_locationManager stopMonitoringForRegion:_regionToMonitor];
    [_locationManager startMonitoringForRegion:_regionToMonitor];
    
    if ([launchOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey] containsObject:RESTORATION_ID]){
        NSLog(@"Peripheral manager exits");
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]) {
           [[AMSConnectionManager sharedManager] restorePeripheral];
        }
    }else {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]) {
            [[AMSConnectionManager sharedManager] stopAdvertising];
        }else {
            [AMSConnectionManager sharedManager];
        }
    }
     
    NSLog(@"Event Mode:%d", [[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]);

    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wifi"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReady object:nil];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ble"]) {
            [self scanForTag];
        }
    } else {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"])
            [self scanForMachine];
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReady object:nil];
            [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
            
            //[SVProgressHUD showSuccessWithStatus:@"Connected"];
        }
            
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [MagicalRecord cleanUp];
}

- (void)scanForMachine {

    self.alertView.title = @"Scanning...";
    [self.alertView show];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kBLEShieldServiceUUIDString];

    self.connectedShield = nil;
    [self.centralManager stopScan];
    [self.centralManager scanForPeripheralsWithServices:@[serviceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

- (void)scanForTag {
    
    [self.peripherals removeAllObjects];
    [self.centralManager stopScan];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:NO];
}

- (void)timerTick:(NSTimer *)timer {
    
    [self.centralManager stopScan];

    if (self.peripheral) {
        for (CBPeripheral *peripheral in self.peripherals) {
            if ([peripheral.name isEqualToString:self.peripheral.name]) {
                [self scanForTag];
                return;
            }
        }
        self.peripheral = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTagLost object:nil];
    }

    for (CBPeripheral *peripheral in self.peripherals) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag = %@", [peripheral.name lowercaseString]];
        NSArray *tags = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tags" ofType:@"plist"]] filteredArrayUsingPredicate:predicate];
        if (tags.count) {
            self.peripheral = peripheral;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTagFound object:[[tags lastObject] valueForKey:@"name"]];
            
            [self scanForTag];
            return;
        }
    }
    
    [self scanForTag];
}

- (void)sendMessage:(NSString *)message {

    NSData *theData = [message dataUsingEncoding:NSASCIIStringEncoding];
    [BLEUtility writeCharacteristic:self.connectedShield
                              sUUID:kBLEShieldServiceUUIDString
                              cUUID:kBLEShieldCharacteristicTXUUIDString
                               data:theData];
}

- (NSString *)getRawHexString:(NSData*)rawData {
    
    NSMutableString *cData = [NSMutableString stringWithCapacity:([rawData length] * 2)];
    const unsigned char *dataBuffer = [rawData bytes];
    int i;
    for (i = 0; i < [rawData length]; ++i) {
        [cData appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    return [NSString stringWithFormat:@"0x%@", [cData uppercaseString]];
}
- (void) restartMonitoring {
    [_locationManager stopMonitoringForRegion:_regionToMonitor];
    [_locationManager startMonitoringForRegion:_regionToMonitor];
    
}
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state == CBCentralManagerStatePoweredOff) {
        
    } else if (central.state == CBCentralManagerStatePoweredOff) {
        
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wifi"] || self.connectedShield) {
        int minRSSI = [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi"];
        if ([RSSI intValue] >= minRSSI) {
            for (CBPeripheral *peripheral in self.peripherals) {
                if ([peripheral.name isEqualToString:self.peripheral.name]) {
                    return;
                }
            }
            [self.peripherals addObject:peripheral];
        }
    } else {
        self.alertView.title = @"Connecting...";
        self.connectedShield = peripheral;
        [self.centralManager stopScan];
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    self.alertView.title = @"Discovering Services...";
    self.connectedShield = peripheral;
    self.connectedShield.delegate = self;
    [self.connectedShield discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    [self scanForMachine];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self scanForMachine];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        CBUUID *serviceUUID = [CBUUID UUIDWithString:kBLEShieldServiceUUIDString];
        if ([service.UUID isEqual:serviceUUID]) {
            self.alertView.title = @"Discovering Characteristics...";
            [self.connectedShield discoverCharacteristics:nil forService:service];

            return;
        }
    }
    [self scanForMachine];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    for (CBCharacteristic *characteristic in service.characteristics) {
        CBUUID *characteristicUUID = [CBUUID UUIDWithString:kBLEShieldCharacteristicTXUUIDString];
        if ([characteristic.UUID isEqual:characteristicUUID]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReady object:nil];
            [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ble"]) {
                [self scanForTag];
            }
            
            [SVProgressHUD showSuccessWithStatus:@"Connected"];
            
            return;
        }
    }
    [self scanForMachine];
}

#pragma mark - CLLocation Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started to monitor for region");
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
    NSLog(@"Failed");
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    if (state == CLRegionStateInside){
        NSLog(@"Beacon is inside");
       [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        [localNotif setAlertBody:@"Inside!"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        if([region.identifier isEqualToString:REGION_ID]){
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]==YES) {
                [[AMSConnectionManager sharedManager] startAdvertising];
                
            }else {
                [[AMSConnectionManager sharedManager] stopAdvertising];
            }
        }
    }else if (state == CLRegionStateOutside){
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        [localNotif setAlertBody:@"Outside!"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];

        NSLog(@"Beacon is Outside");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region");
}

@end
