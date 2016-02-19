//
//  Order.m
//  BTLE Transfer
//
//  Created by Yunus Dawji on 12/31/2013.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import "Order.h"

@implementation Order

-(id) init
{
    //create the NSDictionary with Prices
    self.prices = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"50.25",@"GummyBears",@"61.25",
                    @"SourKeys",@"97.00",
                    @"GumBalls",@"70",
                   @"CokeBottles",@"45.50",
                   @"Worms",@"30.00",
                   @"Peaches",
                   nil];
    
    self.total = NULL;
    self.orderId = NULL;
    
    
    return self;
}

-(NSString *) getPrice: (NSString *)input
{
    return [self.prices objectForKey:input];
}

@end
