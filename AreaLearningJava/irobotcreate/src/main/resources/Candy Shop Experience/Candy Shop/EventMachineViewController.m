//
//  EventMachineViewController.m
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-08-28.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import "EventMachineViewController.h"
#import "EventItemDetailViewController.h"

@interface EventMachineViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cartRightBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@end

@implementation EventMachineViewController

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
    
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"productTitle"]];
    self.navigationItem.titleView = navTitleView;
    
    [self.cartRightBarButton setImage:[self.cartRightBarButton.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.leftBarButtonItem setImage:[self.leftBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)candyPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"itemDetail" sender:sender];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    EventItemDetailViewController *vc = (EventItemDetailViewController *)segue.destinationViewController;
    vc.prizeInfo = [[NSMutableDictionary alloc] init];
    switch ([((UIButton *)sender) tag]) {
            // Lime
        case 0:{
            [vc.prizeInfo setValue:@"Strawberries" forKey:@"name"];
            [vc.prizeInfo setValue:@"strawberries-big" forKey:@"image"];
            break;
        }
            // Coke
        case 1:{
            [vc.prizeInfo setValue:@"Coke Bottles" forKey:@"name"];
            [vc.prizeInfo setValue:@"colaPack" forKey:@"image"];

            break;
        }
            // Worms
        case 2:{
            [vc.prizeInfo setValue:@"Gummy Worms" forKey:@"name"];
            [vc.prizeInfo setValue:@"Gummy_Worms-big" forKey:@"image"];
            break;
        }
            // Melon
        case 3:{
            [vc.prizeInfo setValue:@"Watermelons" forKey:@"name"];
            [vc.prizeInfo setValue:@"watermelon-big" forKey:@"image"];
            break;
        }
            // Whale
        case 4:{
            [vc.prizeInfo setValue:@"Blue Whales" forKey:@"name"];
            [vc.prizeInfo setValue:@"blue-whale-big" forKey:@"image"];
            break;
        }
            // Cherry
        case 5:{
            [vc.prizeInfo setValue:@"Sour Cherries" forKey:@"name"];
            [vc.prizeInfo setValue:@"sour-cherries-big" forKey:@"image"];
            break;
        }
            // Bears
        case 6:{
            [vc.prizeInfo setValue:@"Gummy Bears" forKey:@"name"];
            [vc.prizeInfo setValue:@"gummy-bears-big" forKey:@"image"];
            break;
        }
            // Berries
        case 7:{
            [vc.prizeInfo setValue:@"Berries" forKey:@"name"];
            [vc.prizeInfo setValue:@"berries-big" forKey:@"image"];
            break;
        }
        default:
            break;
    }
    

}
- (IBAction)leftBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
