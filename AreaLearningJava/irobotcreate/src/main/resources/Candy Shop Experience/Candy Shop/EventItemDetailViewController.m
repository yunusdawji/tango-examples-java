//
//  EventItemDetailViewController.m
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-08-29.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import "EventItemDetailViewController.h"
#import "PaySelectionViewController.h"
#import "Order.h"

@interface EventItemDetailViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cartRightBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@end

@implementation EventItemDetailViewController

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
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"productDetailTitle"]];
    self.navigationItem.titleView = navTitleView;
    
    
    [self.cartRightBarButton setImage:[self.cartRightBarButton.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.leftBarButtonItem setImage:[self.leftBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    self.prizeNameLabel.font = [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:30.0f];
    self.prizeNameLabel.text = [self.prizeInfo objectForKey:@"name"];
    [self.prizeNameLabel setText:[self.prizeNameLabel.text uppercaseString]];
    
    NSString *prizeImageName = [self.prizeInfo objectForKey:@"image"];
    UIImage *prizeImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", prizeImageName]];
    self.prizeImageView.image = prizeImage;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)donePressed:(id)sender
{
    [self getCandy];
}


- (void)getCandy
{
    [self performSegueWithIdentifier:@"paymentSelection" sender:self];
}


- (void)returnHome
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PaySelectionViewController * secondcontroller = segue.destinationViewController;
    secondcontroller.orderpay = false;
    secondcontroller.order = [[Order alloc] init];
    secondcontroller.order.total = @"4.25";
    secondcontroller.order.pizzaname = [self.prizeInfo objectForKey:@"name"];
}

- (IBAction)leftBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
