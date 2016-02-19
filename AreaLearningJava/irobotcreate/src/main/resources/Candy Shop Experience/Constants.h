//
//  Constants.h
//  AirMilesStore
//
//  Created by Jeffrey Deng on 2014-05-29.
//  Copyright (c) 2014 Jeffrey Deng. All rights reserved.
//

#ifndef AirMilesStore_Constants_h
#define AirMilesStore_Constants_h

// Broadcasted UDIDs for the store
#define SERVICE_UUID                        @"713D0000-503E-4C75-BA94-3148F18D941E"
#define CHARACTERISTIC_UUID                 @"713D0003-503E-4C75-BA94-3148F18D941E"
#define CALLBACK_CHARACTERISTIC_UUID        @"713D0002-503E-4C75-BA94-3148F18D941E"

// Broadcasted UDIDs for the ad
#define PERSON_SERVICE_INFO_UUID            @"C6243480-CAAB-4196-BB41-77431FDD7697"
#define PERSON_CHARACTERISTIC_NAME_UUID     @"0A2F0E8F-C06C-4932-90C5-ADE7BD9C0D90"

// Testing values
#define COUPON_NUMBER                       @"123COUPON"
#define MEMBER_NUMBER                       @"1234567890"
#define MEMBER_NAME                         @"Christopher"

// Peripheral Manager Restoration ID
#define RESTORATION_ID                      @"airmilesPeripheralRestorationID"

// TYPE OF VALUES
#define CARD                                @"1"
#define COUPON                              @"2"
#define CASH                                @"3"

// iBeacon Advertising UUID
#define BROADCAST_UUID @"5E0960C3-A179-4330-99B8-61190ED7E105"
#define REGION_ID @"com.plastic.advertisment"

#endif
