//
//  EmailViewController.h
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-07.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSString *vendingMessage;
@property (nonatomic, strong) NSString *rowName;
@property (nonatomic, strong) NSDictionary *prizeInfo;

@property (nonatomic, strong) IBOutlet UIImageView *prizeImageView;
@property (nonatomic, strong) IBOutlet UILabel *prizeNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *pointsLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;


- (IBAction)donePressed:(id)sender;
- (IBAction)textFieldChanged:(id)sender;

@end
