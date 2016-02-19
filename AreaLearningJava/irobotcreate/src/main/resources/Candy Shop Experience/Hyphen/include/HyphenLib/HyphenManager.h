//
//  HyphenManager.h
//  Hyphen
//
//  Created by Yunus Dawji on 2014-08-15.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Order.h"
#import "TransferService.h"
#import "EncryptionHelper.h"

@class HyphenManager;

//hyphenmanager delegate protocol
@protocol HyphenManagerDelegate

//delegate is called when order are recieved
-(void) orderDetailsRecieved:(Order *)order;

//delegate is called when transaction is successfull
-(void) transactionSuccessfull:(Order *)order;

//delegate to report error caused by http error or any other error
-(void) reportError:(NSError *)error;

@end

@interface HyphenManager : NSObject<CBPeripheralManagerDelegate, NSURLConnectionDelegate> {

}

@property (nonatomic, assign) id delegate;


@property (nonatomic, readwrite)    Order           *order;
@property (nonatomic, readwrite)    NSMutableData   *responseData;
@property (nonatomic, readwrite)    BOOL            orderpay;

@property (strong, nonatomic)       CBPeripheralManager         *peripheralManager;
@property (nonatomic, readwrite)    NSMutableArray              *subscribedCentrals;

//characteristics for gatt server
@property (strong, nonatomic)       CBMutableCharacteristic     *transferCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *transferNtfyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *paykeyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *confirmkeyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *orderCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *loyaltyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *statusCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *keyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *certficateCharacteristic;

//encrypter
@property (strong, nonatomic)       EncryptionHelper            *encrypter;

//used to store server address intialized by settings
@property (strong, nonatomic)       NSString                    *serverAddress;

@property (strong, nonatomic)       NSDictionary                *urls;

//temporary variables for total and order id
@property (nonatomic, readwrite)    NSString                    *total;
@property (nonatomic, strong)       NSString                    *orderId;
@property (nonatomic,strong)        NSString                    *confirmKey;
@property (nonatomic,strong)        NSString                    *payKey;

//temporary variable for encryptor
@property (strong, nonatomic)       NSMutableData               *publiccertificate;


-(id)initWithParameters:(NSString*) address;

- (void)advertise;

- (void)helloDelegate;

- (void)generateAndSubmitPayKey;

- (void)cancelTransaction:(BOOL)transaction;

-(void)submitorder: (Order *)order;

+(HyphenManager *)sharedManagerWithParameter:(NSString *)parameter;

+(HyphenManager *)sharedManager;



@end
