//
//  CompleteViewController.h
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-07.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompleteViewController : UIViewController

@property (nonatomic, strong) NSString *vendingMessage;

- (IBAction)donePressed:(id)sender;

@end
