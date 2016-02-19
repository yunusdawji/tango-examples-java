//
//  ScratchViewController.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "ScratchViewController.h"
#import "ScratchView.h"
#import "MachineViewController.h"
#import "EventMachineViewController.h"
#import "AMSConnectionManager.h"
//#import "UINavigationBar+CandyShopNavigationBar.h"

@interface ScratchViewController ()
- (BOOL)isWinner;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (strong, nonatomic) IBOutlet UILabel *captionTextLabel;
@end

@implementation ScratchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-bar-title"]];
    self.navigationItem.titleView = navTitleView;
    
    [self.leftBarButtonItem setImage:[self.leftBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    UIImage *coverImage = [UIImage imageNamed:@"scratch-cover"];
    UIImage *couponImage = nil;
    
    [self.captionTextLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]];
    [self.captionTextLabel setText:@"SCRATCH THE BOX ABOVE\nFOR AN EXCLUSIVE\nMOBILE OFFER"];

    
    if([self isWinner])
    {
        _availableCredits = 1000;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]){
            couponImage = [UIImage imageNamed:@"scratch-prize-500"];
        }else{
            couponImage = [UIImage imageNamed:@"scratch-prize-15percent"];
        }    }
    else
    {
        _availableCredits = 500;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]){
            couponImage = [UIImage imageNamed:@"scratch-prize-500"];
        }else{
            couponImage = [UIImage imageNamed:@"scratch-prize-15percent"];
        }
    }

    [self.scratchView configureCoverImage:coverImage andCouponImage:couponImage];
    _instructionLabel.font = [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:24.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]){
    //stop advertising
        [[AMSConnectionManager sharedManager] stopAdvertising];
        
    }else {
        MachineViewController *machineViewController = [segue destinationViewController];
        machineViewController.availableCredits = _availableCredits;
    }

}

#pragma mark - Button Selectors
- (IBAction)doneButtonPressed:(id)sender {
     if([[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]){
         
         [self performSegueWithIdentifier:@"eventMachine" sender:self];
     }else {
         [self performSegueWithIdentifier:@"machine" sender:self];
     }
}

- (IBAction)leftBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Others
- (BOOL)isWinner
{
    float probability = [[NSUserDefaults standardUserDefaults] floatForKey:@"probability"];
    long randNum = random();
    float compare = probability * ((double)RAND_MAX + 1.0);
    return randNum <  compare;
}


@end
