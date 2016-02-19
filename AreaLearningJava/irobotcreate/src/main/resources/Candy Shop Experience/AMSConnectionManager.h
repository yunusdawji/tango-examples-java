//
//  AMSConnectionManager.h
//  AirMilesStore
//
//  Created by Jeffrey Deng on 2014-05-29.
//  Copyright (c) 2014 Jeffrey Deng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AMSPeripheral.h"

@protocol AMSConnectionManagerDelegate <NSObject>

@required
- (void)connectionManagerDidUpdateState:(CBCentralManagerState)state;
- (void)connectionManagerDidFinishScanningWithResults:(NSArray *)scannedPeripherals;
//- (void)connectionManagerdidWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)connectionManagerDidReceiveCallbackNotificationData:(NSData *)notificationData;
- (void)connectionManagerDidLoseConnectionWithPeripheral;
- (void)connectionManagerDidConnectWithPeripheral;
- (void)connectionManagerDidDisconnectWithPeripheral;

@optional
- (void)connectionManagerDidFailToConnectWithPeripheral;
//- (NSData *)peripheralCharacteristicFound
@optional

@end

@interface AMSConnectionManager : NSObject <CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (strong,nonatomic) NSObject<AMSConnectionManagerDelegate> *delegate;
@property (strong,nonatomic) CBUUID *currentSearchUUID;

// A UUID of a characteristic that will receive a notification when the connection is no longer necessary
@property (strong,nonatomic) CBUUID *callbackCharacteristicUUID;

// Dictionary containing UUIDs of characteristics the manager to subscribe to represented by keys
// The values for these keys are the values the manager should write to them
@property (strong,nonatomic) NSDictionary *valuesToWrite;

@property (strong,nonatomic) CBUUID *characteristicToWrite;



+ (AMSConnectionManager *)sharedManager;

- (id)initWithDelegate:(NSObject<AMSConnectionManagerDelegate> *)delegateToSet serviceUUIDToSearch:(CBUUID *)service peripheralCharacteristicToWrite:(CBUUID *)characteristic valuesToWrite:(NSDictionary *)values;

//- (id)initWithDelegate:(NSObject<AMSConnectionManagerDelegate> *)delegateToSet serviceUUIDToSearch:(CBUUID *)service peripheralCharacteristicsAndValuesToWrite:(NSDictionary *)characteristicsAndValues;

- (id)initWithDelegate:(NSObject<AMSConnectionManagerDelegate> *)delegateToSet serviceUUIDToSearch:(CBUUID *)service peripheralCharacteristicToWrite:(CBUUID *)characteristic valuesToWrite:(NSDictionary *)values callbackCharacteristicUUID:(CBUUID *)callbackCharacteristic;

- (void)setServiceUUIDToSearch:(CBUUID *)service peripheralCharacteristicToWrite:(CBUUID *)characteristic valuesToWrite:(NSDictionary *)values callbackCharacteristicUUID:(CBUUID *)callbackCharacteristic;
- (void)restorePeripheral;

// Central
- (BOOL)searchAndConnectToService;
- (void)connectToPeripheral:(AMSPeripheral *)peripheral;
- (void)disconnectConnectedPeripheral;
- (void)stopScanningForService;
- (void)writeToCharacteristics:(CBUUID *)characteristics dataToWrite:(NSData *)data;

// Peripheral
- (void)addService;
- (void)startAdvertising;
- (void)startAdvertisingWithDelay:(float)delay;
- (void)stopAdvertising;
@end
