//
//  AMSConnectionManager.m
//  AirMilesStore
//
//  Created by Jeffrey Deng on 2014-05-29.
//  Copyright (c) 2014 Jeffrey Deng. All rights reserved.
//

#import "AMSConnectionManager.h"
#import "AMSPeripheral.h"
#import "Constants.h"

#define kScanInterval 5

@interface AMSConnectionManager ()

// Peripheral/BLE Emission variables
@property (strong,nonatomic) CBPeripheralManager *peripheralManager;

@property (strong,nonatomic) CBMutableService *personalInfoService;

@property (strong,nonatomic) CBMutableCharacteristic *personalNameCharacteristic;
@property (strong,nonatomic) CBMutableCharacteristic *personalPhotoCharacteristic;
@property (strong,nonatomic) CBMutableCharacteristic *personalLikeCharacteristic;

@property (strong,nonatomic) NSString *personalName;
@property (strong,nonatomic) NSString *personalPhotoURL;
@property (strong,nonatomic) NSString *personalLikeID;

@property (strong,nonatomic) NSMutableDictionary *advertData;

@property (assign,nonatomic) BOOL isReadyToAdvertise;
@property (assign,nonatomic) BOOL didQueueDisconnect;

// Central
@property (strong,nonatomic) NSMutableArray *scannedPeripherals;
@property (strong,nonatomic) AMSPeripheral *connectedPeripheral;

@property (strong,nonatomic) NSTimer *timer;

@end

static AMSConnectionManager *sharedManager;

@implementation AMSConnectionManager

@synthesize delegate;
@synthesize currentSearchUUID;
@synthesize callbackCharacteristicUUID;
@synthesize characteristicToWrite;
@synthesize valuesToWrite;

@synthesize peripheralManager;
@synthesize personalInfoService;
@synthesize personalNameCharacteristic;
@synthesize personalPhotoCharacteristic;
@synthesize personalLikeCharacteristic;
@synthesize personalName;
@synthesize personalPhotoURL;
@synthesize personalLikeID;
@synthesize advertData;
@synthesize isReadyToAdvertise;
@synthesize didQueueDisconnect;

@synthesize connectedPeripheral;
@synthesize scannedPeripherals;
@synthesize timer;

///* Singleton use
#pragma mark - Static Methods
+ (AMSConnectionManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedManager){
            sharedManager = [[AMSConnectionManager alloc] init];
        }
        
    });
    
    return sharedManager;
}
//*/

#pragma mark - Init Methods

- (id)init {
    
    if (self = [super init]){
        //centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        scannedPeripherals = [[NSMutableArray alloc] init];
        connectedPeripheral = nil;
        
        // Peripheral Variable Init
        dispatch_queue_t centralQueue = dispatch_queue_create("com.plastic.AM", DISPATCH_QUEUE_SERIAL);

        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:centralQueue options:@{CBPeripheralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES], CBPeripheralManagerOptionRestoreIdentifierKey:RESTORATION_ID}];
        
        NSString *nameOfPeripheral = @"airmilesStorePeripheral";
        
        advertData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      nameOfPeripheral,
                      CBAdvertisementDataLocalNameKey,
                      [NSArray arrayWithObjects: [CBUUID UUIDWithString:PERSON_SERVICE_INFO_UUID],nil],CBAdvertisementDataServiceUUIDsKey, nil];
        
        isReadyToAdvertise = NO;

        return self;
    }
    return nil;
}

- (id)initWithDelegate:(NSObject<AMSConnectionManagerDelegate> *)delegateToSet serviceUUIDToSearch:(CBUUID *)service peripheralCharacteristicToWrite:(CBUUID *)characteristic valuesToWrite:(NSDictionary *)values callbackCharacteristicUUID:(CBUUID *)callbackCharacteristic {
    
    if (self = [super init]){
        
        // Central Variable init
        delegate = delegateToSet;
        currentSearchUUID = service;
        valuesToWrite = [[NSDictionary alloc] initWithDictionary:values];
        characteristicToWrite = characteristic;
        callbackCharacteristicUUID = callbackCharacteristic;
        NSLog(@"Characteristics: %@",characteristic);
        
        return self;
    }
    return nil;
}

- (void)setServiceUUIDToSearch:(CBUUID *)service peripheralCharacteristicToWrite:(CBUUID *)characteristic valuesToWrite:(NSDictionary *)values callbackCharacteristicUUID:(CBUUID *)callbackCharacteristic {
    
    
    currentSearchUUID = service;
    valuesToWrite = [[NSDictionary alloc] initWithDictionary:values];
    characteristicToWrite = characteristic;
    callbackCharacteristicUUID = callbackCharacteristic;
    NSLog(@"Characteristics: %@",characteristic);
    
}



//- (id)initWithDelegate:(NSObject<AMSConnectionManagerDelegate> *)delegateToSet serviceUUIDToSearch:(CBUUID *)service peripheralCharacteristicsAndValuesToWrite:(NSDictionary *)characteristicsAndValues callbackCharacteristicUUID:(CBUUID *)callbackCharacteristic{
    
    //if (self = [self initWithDelegate:delegateToSet serviceUUIDToSearch:service peripheralCharacteristicToWrite:characteristicsAndValues valuesToWrite:values]){
        
        // Variable init
     //   callbackCharacteristicUUID = callbackCharacteristic;
        
        //NSLog(@"Characteristics: %@",characteristics);
        
    //    return self;
    //}
   // return nil;
//}

- (void)restorePeripheral {
    
    if (!peripheralManager){
        
        dispatch_queue_t centralQueue = dispatch_queue_create("com.plastic.AM", DISPATCH_QUEUE_SERIAL);

        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:centralQueue options:@{CBPeripheralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES], CBPeripheralManagerOptionRestoreIdentifierKey:RESTORATION_ID}];
        
    }else {
        peripheralManager.delegate = self;
    }
}

#pragma mark - Peripheral Functions

// Set up the main service to advertise
- (void)addService {
    
    // Add service or update existing service
    if (peripheralManager.state == CBPeripheralManagerStatePoweredOn){
        
        [peripheralManager removeAllServices];
        
        // CHARACTERISTICS
        // User's name
        NSString *name;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"name"]){
            
            name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        }
        else {
            name = @"";
            [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
        }
        
        personalNameCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:PERSON_CHARACTERISTIC_NAME_UUID] properties:CBCharacteristicPropertyRead value:[name dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable];
        
        // SERVICES
        personalInfoService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:PERSON_SERVICE_INFO_UUID] primary:YES];
        [personalInfoService setCharacteristics:[NSArray arrayWithObjects: personalNameCharacteristic,nil]];
        [peripheralManager addService:personalInfoService];
    }
}

- (void)startAdvertisingWithDelay:(float)delay {
 
    [self performSelector:@selector(startAdvertising) withObject:self afterDelay:delay];
}


// Start advertising the service
- (void)startAdvertising {
    
    if (peripheralManager.state == CBPeripheralManagerStatePoweredOn && !peripheralManager.isAdvertising && isReadyToAdvertise){
        
        // Peripheral Variable Init
        NSString *nameOfPeripheral = @"airmilesStorePeripheral";
        
        advertData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      nameOfPeripheral,
                      CBAdvertisementDataLocalNameKey,
                      [NSArray arrayWithObjects: [CBUUID UUIDWithString:PERSON_SERVICE_INFO_UUID],nil],CBAdvertisementDataServiceUUIDsKey, nil];
        
        [peripheralManager startAdvertising:advertData];
        
        //UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        //[localNotif setAlertBody:@"Advertising"];
        //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }else {
        
        if (peripheralManager.isAdvertising){
            NSLog(@"Already Advertising or stat is off");
            //UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            //[localNotif setAlertBody:@"Already advertising"];
            //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        }
    }
}

- (void)stopAdvertising {
    if (peripheralManager.state == CBPeripheralManagerStatePoweredOn && peripheralManager.isAdvertising){

        NSLog(@"Stopped advertising");
        [peripheralManager stopAdvertising];

    }else {
        
        if (!peripheralManager.isAdvertising){
            NSLog(@"Already not advertising or stat is off");
        }
    }
}

#pragma mark - Peripheral Manager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:{
            NSLog(@"Current State Unknown");
            break;
        }
        case CBPeripheralManagerStateResetting:{
            NSLog(@"Current State Resetting");
            break;
        }
        case CBPeripheralManagerStatePoweredOn:{
            
            NSLog(@"Current State On");
            [self addService];
            break;
        }
        case CBPeripheralManagerStatePoweredOff: {
            
            NSLog(@"Current State Off");
            break;
        }
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }else {
        
        NSLog(@"Added Service");
        isReadyToAdvertise = YES;
        
        if (!peripheral.isAdvertising){
            
            [peripheral startAdvertising:advertData];
            NSLog(@"Peripheral Name %@", advertData[CBAdvertisementDataLocalNameKey]);
        }
    }
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    
    NSLog(@"Advertising");
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request {
    
    if ([request.characteristic.UUID isEqual:[CBUUID UUIDWithString:PERSON_CHARACTERISTIC_NAME_UUID]]) {
        
        if (request.offset > personalNameCharacteristic.value.length) {
            [peripheralManager respondToRequest:request
                                     withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        request.value = [personalNameCharacteristic.value
                         subdataWithRange:NSMakeRange(request.offset,
                                                      personalNameCharacteristic.value.length - request.offset)];
    }
    
    [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    if ([characteristic isEqual:personalNameCharacteristic]){
        
        NSData *updatedValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"];
        BOOL didSendValue = [peripheralManager updateValue:updatedValue
                                         forCharacteristic:personalNameCharacteristic onSubscribedCentrals:nil];
        
        if (!didSendValue){
            
            NSLog(@"Unable to update subscribed characteristices: Central Queue Full");
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    
    if (dict[CBPeripheralManagerRestoredStateAdvertisementDataKey]){
        [peripheralManager startAdvertising:dict[CBPeripheralManagerRestoredStateAdvertisementDataKey]];
    }
}

@end
