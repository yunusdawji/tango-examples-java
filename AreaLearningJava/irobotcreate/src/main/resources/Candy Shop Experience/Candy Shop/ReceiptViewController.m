//
//  ReceiptViewController.m
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-08-29.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import "ReceiptViewController.h"
#import "AppDelegate.h"

@interface ReceiptViewController ()
@property (strong, nonatomic) IBOutlet UILabel *receiptTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *calculationsLabel;
@property (strong, nonatomic) IBOutlet UILabel *calculationPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *paymentLabel;
@property (strong, nonatomic) IBOutlet UILabel *paymentDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;

@end

@implementation ReceiptViewController

@synthesize receiptTitleLabel;
@synthesize itemLabel;
@synthesize itemPriceLabel;
@synthesize calculationPriceLabel;
@synthesize calculationsLabel;
@synthesize paymentLabel;
@synthesize paymentDetailLabel;
@synthesize order;
@synthesize pointsLabel;

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
    
    self.navigationItem.hidesBackButton = YES;
    
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"receiptTitle"]];
    self.navigationItem.titleView = navTitleView;
    
    [receiptTitleLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:15.0f]];
    
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy h:mm"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    
    [receiptTitleLabel setText:[NSString stringWithFormat:@"100 N. Third St\nAZ, Phoenix,85004\n1.800.282.4842\n%@",resultString]];
    
    
    // Item
    [itemLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]];
    [itemLabel setText:[NSString stringWithFormat:@"1 %@",order.pizzaname]];
    
    // Item Price
    [itemPriceLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]];
    [itemPriceLabel setText:@"$5.00"];
    
    // Calculations
    NSDictionary *calculationsLabelAttribs = @{
                                               NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]
                                               };
    NSMutableAttributedString *calculationsLabelAttributedText =
    [[NSMutableAttributedString alloc] initWithString:@"SUB TOTAL:\nDISCOUNT:\nTOTAL:"
                                           attributes:calculationsLabelAttribs];
    
    UIColor *pinkColor = [UIColor colorWithRed:.874509804 green:.098039216 blue:.337254902 alpha:1];
    NSRange pinkColorRange = [calculationsLabelAttributedText.string rangeOfString:@"\nTOTAL:"];
    [calculationsLabelAttributedText setAttributes:@{NSForegroundColorAttributeName:pinkColor,
                                                     NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskBE-MdCn" size:25.0f]
                                                     }
                                             range:pinkColorRange];
    
    [calculationsLabel setAttributedText:calculationsLabelAttributedText];
    
    // Calculations Detail
    NSDictionary *calculationPriceLabelAttribs = @{
                                                   NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]
                                                   };
    NSMutableAttributedString *calculationPriceLabelAttributedText =
    [[NSMutableAttributedString alloc] initWithString:@"$5.00\n15%\n$4.25"
                                           attributes:calculationPriceLabelAttribs];
    
    pinkColorRange = [calculationPriceLabelAttributedText.string rangeOfString:@"$4.25"];
    [calculationPriceLabelAttributedText setAttributes:@{NSForegroundColorAttributeName:pinkColor,
                                                     NSFontAttributeName: [UIFont fontWithName:@"AkzidenzGroteskBE-MdCn" size:25.0f]}
                                             range:pinkColorRange];
    
    [calculationPriceLabel setAttributedText:calculationPriceLabelAttributedText];
    
    // Payment Label
    [paymentLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]];
    [paymentLabel setText:@"PAYMENT METHOD\nUSER NAME\nLOYALTY #\n"];
    
    // Payment Label
    [paymentDetailLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]];
    
    [paymentDetailLabel setText:[NSString stringWithFormat:@"%@\nTAYLOR SMITH\n57129",@"CREDIT"]];
    
    
    [pointsLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-MdCn" size:30.0f]];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate restartMonitoring];
    
    exit(0);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
