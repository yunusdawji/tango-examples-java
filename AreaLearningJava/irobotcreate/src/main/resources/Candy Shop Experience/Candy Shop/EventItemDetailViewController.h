//
//  EventItemDetailViewController.h
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-08-29.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventItemDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *prizeInfo;

@property (nonatomic, strong) IBOutlet UIImageView *prizeImageView;
@property (nonatomic, strong) IBOutlet UILabel *prizeNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;


- (IBAction)donePressed:(id)sender;

@end
