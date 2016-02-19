//
//  Order.h
//  BTLE Transfer
//
//  Created by Yunus Dawji on 12/31/2013.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject
@property (nonatomic,readwrite) NSString    *pizzaname;
@property (nonatomic,readwrite) NSDictionary *prices;
@property (nonatomic,readwrite) NSString    *total;
@property (nonatomic,readwrite) NSString    *orderId;

-(NSString *) getPrice: (NSString *)input;


@end
