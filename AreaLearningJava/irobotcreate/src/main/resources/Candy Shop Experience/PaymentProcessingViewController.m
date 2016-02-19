#import "PaymentProcessingViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HyphenManager.h"
#import "TransferService.h"
#import "AppDelegate.h"
#import "EncryptionHelper.h"
#import "ReceiptViewController.h"
#import "BearActivityIndicatorview.h"

@interface PaymentProcessingViewController () <HyphenManagerDelegate, UITextViewDelegate>

// Code ripped from Hyphen
@property (strong, nonatomic) IBOutlet UITextView               *textView;
@property (strong, nonatomic) IBOutlet UISwitch                 *advertisingSwitch;
@property (weak, nonatomic)   IBOutlet UIButton                 *udateCharacteristics;
@property (nonatomic, strong)       UIAlertView                 *alert;
@property (nonatomic, strong)       UIActivityIndicatorView     *indicator;


@property (strong, nonatomic)       CBPeripheralManager         *peripheralManager;
@property (strong, nonatomic)       CBMutableCharacteristic     *transferCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *transferNtfyCharacteristic;
@property (nonatomic, readwrite)    NSMutableArray              *subscribedCentrals;
@property (strong, nonatomic)       CBMutableCharacteristic     *paykeyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *confirmkeyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *orderCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *loyaltyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *statusCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *keyCharacteristic;
@property (strong, nonatomic)       CBMutableCharacteristic     *certficateCharacteristic;

@property (strong, nonatomic)       NSData                      *dataToSend;
@property (strong,nonatomic)        NSMutableData               *tempdata;
@property (nonatomic, readwrite)    NSInteger                   sendDataIndex;
@property (nonatomic, readwrite)    NSString                    *total;
@property (nonatomic, strong)       NSString                    *order_id;
@property (nonatomic, strong)       NSString                    *paykey;
@property (nonatomic, strong)       NSString                    *confirmkey;
@property (weak, nonatomic) IBOutlet UIButton                   *btnAcceptTransaction;
@property (weak, nonatomic) IBOutlet UIButton                   *btnDismissTransaction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *spinner;
@property (weak, nonatomic) IBOutlet UIImageView                *imageView;
@property (strong, nonatomic)       NSString                    *server_address;
@property (strong, nonatomic)       EncryptionHelper            *encrypter;
@property (strong, nonatomic)       NSMutableData               *publiccertificate;

@property (strong, nonatomic)       HyphenManager               *hyphenManager;

// Custom Candy App Code
@property (strong, nonatomic) IBOutlet UILabel *processPaymentTextLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cartRightBarButton;

@end


#define NOTIFY_MTU      20


@implementation PaymentProcessingViewController

@synthesize encrypter;


#pragma mark - View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    // UI
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkOutTitle"]];
    self.navigationItem.titleView = navTitleView;
    
    [self.processPaymentTextLabel setFont:[UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:30.0f]];
    [self.processPaymentTextLabel setText:@"We are processing\nyour payment"];
    
    [self.cartRightBarButton setImage:[self.cartRightBarButton.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // Connection
    CBCentralManager *tempcentral = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    [tempcentral stopScan];
    
    encrypter = [[EncryptionHelper alloc] init];
    
    // Start up the CBPeripheralManager
    //self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey:@1 }];
    
    //self.subscribedCentrals = [NSMutableArray array];
    
    //[self advertise];
    
    // start avertising
    //[self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    
    
    // NSLog(@"Order Received : %@",[self.order getPrice:self.order.pizzaname]);
    
    
    // show waiting
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.imageView.image = [UIImage imageNamed:@"screen_connecting.png"];
    //[self.view addSubview:theBackground];

    [self.btnAcceptTransaction.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:34.0]];
    [self.btnDismissTransaction.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:34.0]];

    [self.btnAcceptTransaction setEnabled:false];
    [self.btnDismissTransaction setEnabled:false];
    self.btnAcceptTransaction.hidden = YES;
    self.btnDismissTransaction.hidden = YES;

  //  [self.btnAcceptTransaction addTarget:self action:@selector(btnAcceptClicked) forControlEvents:UIControlEventTouchUpInside];
    
   // [self.btnDismissTransaction addTarget:self action:@selector(openLeftMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.hidesBackButton = YES;

    
    //intialize the public certificate object
    self.publiccertificate = [[NSMutableData alloc] init];
    
    //load the server address
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.server_address = [defaults objectForKey:@"serveraddress"];
    
    
    //hyphen manager
    self.hyphenManager = [HyphenManager sharedManagerWithParameter:self.server_address ];
    //[[HyphenManager alloc] initWithParameters:self.server_address];
    
    [self.hyphenManager setDelegate:self];
    
    // Bear Activity indicator
    BearActivityIndicatorView *indicatorView =[[BearActivityIndicatorView alloc] init];
    [indicatorView setCenter:CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.55)];
    [self.view addSubview:indicatorView];
    
}

- (void) openLeftMenu:(id)sender {
    if(self.navigationController.viewControllers.count > 1) {
        BOOL temp = NO;
        [self.hyphenManager cancelTransaction:temp];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated{
   // [self performSegueWithIdentifier:@"receipt" sender:self];

    
    }

-(UIBarButtonItem *) barButtonItemWithImage:(UIImage *) image target:(id) target action:(SEL) action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0, image.size.width-10, image.size.height-10);
    [button setImage: image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [self.peripheralManager stopAdvertising];
    [encrypter deleteSymmetricKey];

    
    [super viewWillDisappear:animated];

}

-(void)btnAcceptClicked{
    
        NSLog(@"Customer wants to pay");
    
        [self.hyphenManager generateAndSubmitPayKey];
    
}
         
//not used anymore
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"Customer wants to pay");
        
        //random key generator of lenght '15'
        NSMutableString* string = [NSMutableString stringWithCapacity:15];
        for (int i = 0; i < 15; i++) {
            [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
        }
        
        self.paykey = string;
        
        NSLog(@"Alert View Payment Key:%@",self.paykey);
        
        //update payment key
        //data to post
        NSString *post = [NSString stringWithFormat:@"&order_id=%@&payment_key=%@",self.order_id ,self.paykey];
        //encode data
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:CONFIRM_PAYMENT]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setHTTPBody:postData];
        
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        if(conn)
        {
            NSLog(@"ViewLoad : HTTP Connection Successful");
        }
        else
        {
            NSLog(@"ViewLoad : HTTP Connection could not be made");
        }

        [self.alert show];
        
    }
}

#pragma mark - TextView Methods



/** This is called when a change happens, so we know to stop advertising
 */
- (void)textViewDidChange:(UITextView *)textView
{
    // If we're already advertising, stop
    if (self.advertisingSwitch.on) {
        [self.advertisingSwitch setOn:NO];
      //  [self.peripheralManager stopAdvertising];
    }
}


/** Adds the 'Done' button to the title bar
 */
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // We need to add this manually so we have a way to dismiss the keyboard
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


/** Finishes the editing */
- (void)dismissKeyboard
{
    [self.textView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
            
    //ALAsset *asset = self.assets[indexPath.row];
    //cell.asset = asset;
    //cell.backgroundColor = [UIColor redColor];

    return cell;
}
         

#pragma mark - Switch Methods

/** 
 * Start advertising
 *
 */

- (IBAction)switchChanged:(id)sender
{
    if (self.advertisingSwitch.on) {
        // All we advertise is our service's UUID
      //  [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
    
    else {
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - Button Methods

- (IBAction)buttonClicked:(id)sender
{
    self.tempdata = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    self.transferCharacteristic.value = self.tempdata;

   NSLog(@"%@", [[NSString alloc] initWithData:self.transferCharacteristic.value encoding:NSASCIIStringEncoding ]);
    
}
/*
 *
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSLog(@"Received HTTP Response");
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // Append the new data to the instance variable you declared
    NSLog(@"Received HTTP Response");
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding ]);
    NSString* recievedata = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding ];
    
    //if response from submitorder.php
    if([recievedata rangeOfString:@"Order Submitted :"].location!=NSNotFound)
    {
        
        //update the characteristics with order number
        self.order_id = [recievedata substringFromIndex:18];
        self.tempdata = [self.order_id dataUsingEncoding:NSUTF8StringEncoding];
        self.transferCharacteristic.value = [encrypter encryptWithAES:self.tempdata key:encrypter.symmetricKey];
        [self.peripheralManager updateValue:[encrypter encryptWithAES:self.tempdata key:encrypter.symmetricKey] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        NSLog(@"Received HTTP Response %@",self.order_id );

    }
    else if ([recievedata rangeOfString:@"Payment Key Update :"].location!=NSNotFound)
    {
        
        if([recievedata rangeOfString:@"Success"].location!=NSNotFound)
        {
            self.paykeyCharacteristic.value = [encrypter encryptWithAES:[self.paykey dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
            [self.peripheralManager updateValue:[encrypter encryptWithAES:[self.paykey dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey] forCharacteristic:self.paykeyCharacteristic onSubscribedCentrals:nil];
            
        }
        else
        {
            self.alert.title = @"Something Went Wrong";
        }
    }
    else if ([recievedata rangeOfString:@"Confirm Key Check :"].location!=NSNotFound)
    {
        
        if([recievedata rangeOfString:@"Success"].location!=NSNotFound)
        {
            [self.peripheralManager updateValue:[encrypter encryptWithAES:[CONFIRMKEYMATCHEDCODE dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            //print the detailed reciept and update the view
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            [self.spinner stopAnimating];
            self.imageView.image = [UIImage imageNamed:@"screen_5.png"];
            
            NSArray *viewsToRemove = [self.view subviews];
            for (UIView *v in viewsToRemove) {
                if (![v isEqual:self.imageView]) {
                    [v removeFromSuperview];
                }
                
            }
            //if default pay used
            UIImageView *theBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
            [theBackground setContentMode:UIViewContentModeScaleAspectFit];
            theBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
            theBackground.frame = CGRectMake(30,210, 55, 235);
            [theBackground setContentMode:UIViewContentModeScaleAspectFit];
            
            if (self.order.pizzaname.length==0) {
                NSLog(@"%@",self.order.pizzaname);
                theBackground.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"GummyBears.png"]];
            }
            else
            {
            theBackground.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@.png", self.order.pizzaname]];
            }
                
            [self.view addSubview:theBackground];
            
            UITextView *theText = [[UITextView alloc] initWithFrame:self.view.bounds];
            theText.frame = CGRectMake(90, 283, self.view.frame.size.width, self.view.frame.size.height);
            theText.backgroundColor = [UIColor clearColor];
            
            if (self.order.pizzaname.length==0) {
                theText.text = @"GummyBears";
            }
            else
            {
                theText.text = self.order.pizzaname;
            }
            
            [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:16]];
            [theText setEditable:false];
            [self.view addSubview:theText];
            
            theText = [[UITextView alloc] initWithFrame:self.view.bounds];
            theText.frame = CGRectMake(250, 283, self.view.frame.size.width, self.view.frame.size.height);
            theText.backgroundColor = [UIColor clearColor];
            
            if (self.order.pizzaname.length==0) {
                theText.text = self.total;
            }
            else
            {
            theText.text = [self.order getPrice:self.order.pizzaname];
            }
            [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:16]];
            [theText setEditable:false];
            
            [self.view addSubview:theText];
            
            theText = [[UITextView alloc] initWithFrame:self.view.bounds];
            theText.frame = CGRectMake(124, 419, self.view.frame.size.width, self.view.frame.size.height);
            theText.backgroundColor = [UIColor clearColor];
            if (self.order.pizzaname.length==0) {
                
                theText.text = [[NSString alloc] initWithFormat:@"$ %@",self.total];
            }
            else
            {
                theText.text = [[NSString alloc] initWithFormat:@"$ %@",[self.order getPrice:self.order.pizzaname]];
            }
            [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:18]];
            theText.font = [UIFont boldSystemFontOfSize:18];
            [theText setEditable:false];
            [self.view addSubview:theText];
            //self.view.bounds = myViewController.view.bounds;
            
            //self.alert = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] ;
            [self.btnAcceptTransaction setEnabled:false];
            [self.btnDismissTransaction setEnabled:false];
            self.btnAcceptTransaction.hidden = true;
            self.btnDismissTransaction.hidden = true;
            
            self.alert = [[UIAlertView alloc] initWithTitle:@"Thank You For Your Bussiness" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            //[self.alert setCancelButtonIndex:[self.alert addButtonWithTitle:@"Done"]];
            //[self.alert show];
            
            [self.peripheralManager stopAdvertising];
        }
        else
        {
            self.alert.title = @"Something Went Wrong";
            [self.peripheralManager updateValue:[encrypter encryptWithAES:[CONFIRMKEYFAILEDCODE dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        }
    }
    [_responseData appendData:data];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
       if (buttonIndex == [alertView cancelButtonIndex]){
           NSLog(@"Done");
          // [self.navigationController popToRootViewControllerAnimated:YES];
           // [self.navigationController popViewControllerAnimated:YES];
         //  [self.navigationItem.backBarButtonItem   sendActionsForControlEvents:UIControlEventTouchUpInside];
       }else{
           //reset clicked
       }
}
         
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
}

*/

#pragma hyphen delegates
-(void)orderRecieved:(Order *)order {
    //////////////////////////////////////////////////////////////////////////////////
    // CANDY SHOP EXPERIEINCE
    //////////////////////////////////////////////////////////////////////////////////
    // Send data to server
    
    // <Buyer ID> <Order ID> <Quantity> <candyName> <Price> <Discount>
    //
    NSString *tempurl = [[NSString alloc] initWithFormat:@"%@data",[[NSUserDefaults standardUserDefaults] stringForKey:@"orderserveraddress"] ];
    
    NSString *post = [NSString stringWithFormat:@"buyerid=%@&orderid=%@&quantity=1&candy=%@&priceper=5.00&discount=15&total=4.25",@"1",order.orderId,self.order.pizzaname];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    
    
    [request setURL:[NSURL URLWithString:tempurl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *newQueue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:newQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError){
            NSLog(@"ERROR:%@",connectionError);
        }else {
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             #warning TODO REMOVE WHEN HYPHEN IS ADDED
             // [self transactionSuccessfull:self.order];
             });
             */
            NSLog(@"SUCCESS");

        }
    }];

}

-(void) orderDetailsRecieved:(Order *)order {
    
    
   
    
    [self.hyphenManager generateAndSubmitPayKey];
    /*
     *
    [self.spinner stopAnimating];
    [self.imageView setImage:[UIImage imageNamed:@"screen_4.png"]];
    
    UITextView *theText = [[UITextView alloc] initWithFrame:self.view.bounds];
    theText.frame = CGRectMake(112, 241, 100, 100);
    theText.backgroundColor = [UIColor clearColor];
    theText.text = order.total;
    
    [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:34]];
    theText.font = [UIFont boldSystemFontOfSize:34];
    
    [self.view addSubview:theText];
    
    theText = [[UITextView alloc] initWithFrame:self.view.bounds];
    theText.frame = CGRectMake(189, 282, 100, 100);
    theText.backgroundColor = [UIColor clearColor];
    theText.text = order.orderId;
    
    [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:34]];
    theText.font = [UIFont boldSystemFontOfSize:34];
    
    [self.view addSubview:theText];
    
    //set button to true
    [self.btnAcceptTransaction setEnabled:true];
    [self.btnDismissTransaction setEnabled:true];
    self.btnAcceptTransaction.hidden = false;
    self.btnDismissTransaction.hidden = false;
     *
     */

}

-(void) transactionSuccessfull:(Order *)order
{
    [self performSegueWithIdentifier:@"receipt" sender:self];
    /*
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    [self.spinner stopAnimating];
    self.imageView.image = [UIImage imageNamed:@"screen_5.png"];
    
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isEqual:self.imageView]) {
            [v removeFromSuperview];
        }
    }
    
    //if default pay used
    UIImageView *theBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [theBackground setContentMode:UIViewContentModeScaleAspectFit];
    theBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
    theBackground.frame = CGRectMake(30,210, 55, 235);
    [theBackground setContentMode:UIViewContentModeScaleAspectFit];
    
    if (order.pizzaname.length==0) {
        NSLog(@"%@",order.pizzaname);
        theBackground.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"GummyBears.png"]];
    }
    else
    {
        theBackground.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@.png", order.pizzaname]];
    }
    
    [self.view addSubview:theBackground];
    
    UITextView *theText = [[UITextView alloc] initWithFrame:self.view.bounds];
    theText.frame = CGRectMake(90, 283, self.view.frame.size.width, self.view.frame.size.height);
    theText.backgroundColor = [UIColor clearColor];
    
    if (order.pizzaname.length==0) {
        theText.text = @"GummyBears";
    }
    else
    {
        theText.text = order.pizzaname;
    }
    
    [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:16]];
    [theText setEditable:false];
    [self.view addSubview:theText];
    
    theText = [[UITextView alloc] initWithFrame:self.view.bounds];
    theText.frame = CGRectMake(250, 283, self.view.frame.size.width, self.view.frame.size.height);
    theText.backgroundColor = [UIColor clearColor];
    
    if (order.pizzaname.length==0) {
        theText.text = order.total;
    }
    else
    {
        theText.text = [order getPrice:order.pizzaname];
    }
    [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:16]];
    [theText setEditable:false];
    
    [self.view addSubview:theText];
    
    theText = [[UITextView alloc] initWithFrame:self.view.bounds];
    theText.frame = CGRectMake(124, 419, self.view.frame.size.width, self.view.frame.size.height);
    theText.backgroundColor = [UIColor clearColor];
    if (order.pizzaname.length==0) {
        
        theText.text = [[NSString alloc] initWithFormat:@"$ %@",order.total];
    }
    else
    {
        theText.text = [[NSString alloc] initWithFormat:@"$ %@",[order getPrice:order.pizzaname]];
    }
    [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:18]];
    theText.font = [UIFont boldSystemFontOfSize:18];
    [theText setEditable:false];
    [self.view addSubview:theText];
    //self.view.bounds = myViewController.view.bounds;
    
    //self.alert = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] ;
    [self.btnAcceptTransaction setEnabled:false];
    [self.btnDismissTransaction setEnabled:false];
    self.btnAcceptTransaction.hidden = true;
    self.btnDismissTransaction.hidden = true;
    
    self.alert = [[UIAlertView alloc] initWithTitle:@"Thank You For Your Bussiness" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    //[self.alert setCancelButtonIndex:[self.alert addButtonWithTitle:@"Done"]];
    //[self.alert show];
*/
}

-(void) reportError:(NSError *)error
{
    if ([[error domain] isEqualToString:kHTTPERRORDOMAIN]) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [self.alert setCancelButtonIndex:[self.alert addButtonWithTitle:@"Done"]];
        [self.alert show];
    }
    else if ([[error domain] isEqualToString:kPAYKEYUPDATEFAILEDERRORDOMAIN]) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [self.alert setCancelButtonIndex:[self.alert addButtonWithTitle:@"Done"]];
        [self.alert show];
    }
    else if ([[ error domain] isEqualToString:kCONFIRMKEYMATCHFAILEDERRORDOMAIN]){
        self.alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [self.alert setCancelButtonIndex:[self.alert addButtonWithTitle:@"Done"]];
        [self.alert show];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    ReceiptViewController *recVC = (ReceiptViewController *)segue.destinationViewController;
    [recVC setOrder:self.order];
    
}

@end
