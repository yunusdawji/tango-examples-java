/*
 
 File: ViewController.m
 
 Abstract: View Controller to select whether the App runs in Central or
 Peripheral Mode
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "PaySelectionViewController.h"
#import "PaymentProcessingViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import "AMSConnectionManager.h"
#import "HyphenManager.h"

@interface PaySelectionViewController ()

@property (weak, nonatomic) IBOutlet UIButton               *creditPay;
@property (weak, nonatomic) IBOutlet UIButton               *orderPay;
@property (strong, nonatomic)        CBCentralManager       *centralManager;
@property (strong, nonatomic)        CBPeripheral           *discoveredPeripheral;
@property (strong, nonatomic) IBOutlet UIButton *debitPay;
@property (strong, nonatomic) IBOutlet UIButton *cashPay;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;

@property (strong, nonatomic)       HyphenManager               *hyphenManager;


@end

@implementation PaySelectionViewController

@synthesize titleLabel;
@synthesize amountLabel;
@synthesize captionLabel;
@synthesize hyphenManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"productTitle"]];
    self.navigationItem.titleView = navTitleView;
    
    self.navigationItem.hidesBackButton = YES;

    //set fonts
    [self.creditPay.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:26.0]];
    [self.orderPay.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:26.0]];
    [titleLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-MdCn" size:30.0f]];
    [amountLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-MdCn" size:55.0f]];
    [captionLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:25.0f]];

    
    // Disable payment buttons
    self.orderPay.hidden = true;
    self.orderPay.enabled = false;
    
    
    // Start up the CBCentralManager
    //self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //load the server address
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //self.server_address = [defaults objectForKey:@"serveraddress"];
    
    
    //hyphen manager
    hyphenManager = [HyphenManager sharedManagerWithParameter:[defaults objectForKey:@"serveraddress"] ];
    
    
}
/*
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...@[[CBUUID UUIDWithString:SERVICE_UUID]
    
    // ... so start scanning
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -85) {
        return;
    }
    NSLog(@"%@", [advertisementData allKeys]);
   // NSLog([advertisementData allKeys]);
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // Ok, it's in range - have we already seen it?
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        
        if ([[[peripheral identifier] UUIDString] isEqualToString:@"9285C33B-DA65-ABD8-C200-594D815828B5"] && RSSI.integerValue > -50 && RSSI.integerValue < -25) {
            self.creditPay.enabled = true;
            [self.centralManager stopScan];
        }
       //[self.centralManager connectPeripheral:peripheral options:nil];
    }
}
*/
#pragma mark - Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.centralManager stopScan];
    if ([[segue identifier] isEqualToString:@"directPay" ]) {
        
        //set the order details
        self.orderpay = false;
        PaymentProcessingViewController* secondcontroller = segue.destinationViewController;
        secondcontroller.orderpay = self.orderpay;
        secondcontroller.order = self.order;
        
    }
    else if ([[segue identifier] isEqualToString:@"orderPay"])
    {
        // self.orderpay = true;
        // MainViewController* secondcontroller = segue.destinationViewController;
        // secondcontroller.orderpay = self.orderpay;
    }
    
}

#pragma mark - Button Handlers

- (IBAction)cashButtonPressed:(id)sender {}

- (IBAction)creditButtonPressed:(id)sender {
    [hyphenManager submitorder:self.order];
    [self performSegueWithIdentifier:@"directPay" sender:self];

}
- (IBAction)debitButtonPressed:(id)sender {
    [hyphenManager submitorder:self.order];
    [self performSegueWithIdentifier:@"directPay" sender:self];

}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
