//
//  ReceiptViewController.h
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-08-29.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface ReceiptViewController : UIViewController
@property (nonatomic, readwrite) Order *order;
@end
