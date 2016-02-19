//
//  HyphenManager.m
//  Hyphen
//
//  Created by Yunus Dawji on 2014-08-15.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "HyphenManager.h"


@implementation HyphenManager

//synthesize
@synthesize delegate;
@synthesize peripheralManager;
@synthesize subscribedCentrals;
@synthesize encrypter;
@synthesize urls;
@synthesize serverAddress;

static HyphenManager *sharedManager;

+(HyphenManager *)sharedManagerWithParameter:(NSString *)parameter {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedManager){
            sharedManager = [[HyphenManager alloc] initWithParameters:parameter];
        }
    });
    return sharedManager;
}

+(HyphenManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedManager){
            sharedManager = [[HyphenManager alloc] initWithParameters:nil];
        }
    });
    return sharedManager;

}


-(id)initWithParameters:(NSString*) address {
    self = [super init];

    serverAddress = address;
    
    //intialize url dictionary
    urls = [[NSDictionary alloc]
            initWithObjectsAndKeys:
            [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverAddress,SUBMIT_ORDER_URL]], kSUBMIT_ORDER_URL,
            [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverAddress,VERIFY_URL]], kVERIFY_URL,
            [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverAddress,CONFIRM_PAYMENT]], kCONFIRM_PAYMENT,
            nil];
    
    //intialize the encrypter
    encrypter = [[EncryptionHelper alloc] init];
    
    // Start up the CBPeripheralManager
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey:@1 }];
    subscribedCentrals = [NSMutableArray array];
    
    
    
    //intialize the public certificate object
    self.publiccertificate = [[NSMutableData alloc] init];

    self.toAdvertise = NO;

    
    return self;
}



- (void) advertise
{
    if(self.peripheralManager.state == CBPeripheralManagerStatePoweredOn)
    {
        //start avertising
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
    else
    {
        self.toAdvertise = YES;
    }
}

- (void) peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"Start Advertisment Request %@", error.description);
}

/**
 *  Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        //start avertising but this can cause endloop
        
        return;
    }
    
    NSLog(@"self.peripheralManager powered on.");
    
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.orderCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:ORDERNO_CHARACTERISTIC_UUID]
                                                                  properties:CBCharacteristicPropertyRead |CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify
                                                                       value:nil
                                                                 permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyRead |CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    self.transferNtfyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTICNF_UUID]
                                                                         properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify
                                                                              value:nil
                                                                        permissions:CBAttributePermissionsWriteable];
    self.paykeyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:PAYKEY_CHARACTERISTIC_UUID]
                                                                   properties:CBCharacteristicPropertyRead |CBCharacteristicPropertyNotify
                                                                        value:nil
                                                                  permissions:CBAttributePermissionsReadable];
    self.confirmkeyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CONFIRMKEY_CHARACTERISTIC_UUID]
                                                                       properties:CBCharacteristicPropertyWrite
                                                                            value:nil
                                                                      permissions:CBAttributePermissionsWriteable];
    
    self.loyaltyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:LOYALTY_CHARACTERISTIC_UUID]
                                                                    properties:CBCharacteristicPropertyRead
                                                                         value:nil
                                                                   permissions:CBAttributePermissionsReadable];
    
    self.statusCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:STATUS_CHARACTERISTIC_UUID]
                                                                   properties:CBCharacteristicPropertyRead |CBCharacteristicPropertyNotify
                                                                        value:nil
                                                                  permissions:CBAttributePermissionsReadable];
    self.keyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:KEY_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify  value:nil permissions:CBAttributePermissionsReadable];
    
    self.certficateCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CERTIFICATE_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyWrite  value:nil permissions:CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    NSArray* characteristicsArray = [NSArray arrayWithObjects:self.orderCharacteristic,self.confirmkeyCharacteristic, self.paykeyCharacteristic, self.transferNtfyCharacteristic,self.transferCharacteristic, self.loyaltyCharacteristic, self.statusCharacteristic, self.keyCharacteristic , self.certficateCharacteristic, nil];
    
    transferService.characteristics = characteristicsArray;
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
    
    //update the values for charactersitics
    if (self.orderpay) {
        self.orderCharacteristic.value = [encrypter encryptWithAES:[@"0" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
    }
    else
    {
        self.orderCharacteristic.value = [encrypter encryptWithAES:[@"1" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
        
    }
    
    //set loyalty number
    self.loyaltyCharacteristic.value = [encrypter encryptWithAES:[@"777" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
    
    // self.keyCharacteristic.value = [encrypter encryptWithRSA:encrypter.symmetricKey];
    
    //start avertising
    if (self.toAdvertise) {
        self.toAdvertise = NO;
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
        
    }
    /*
     *
     *
    // if ordered sumbit order using http at load else retrive total
    if(self.orderpay){
        
        // data to post
        NSString *post = [NSString stringWithFormat:@"&total=%@&customer_id=%@",[self.order getPrice:self.order.pizzaname],@"1"];
        // encode data
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.serverAddress,SUBMIT_ORDER_URL]]];
        
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
        
    }
     */
    
}

-(void)setOrderPay: (BOOL)orderpay
{
    //update the values for charactersitics
    if (self.orderpay) {
        self.orderCharacteristic.value = [encrypter encryptWithAES:[@"0" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
    }
    else
    {
        self.orderCharacteristic.value = [encrypter encryptWithAES:[@"1" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
        
    }
}

-(void)submitorder: (Order *)order
{
    // data to post
    NSString *post = [NSString stringWithFormat:@"&total=%@&customer_id=%@",order.total,@"1"];
    self.order = [[Order alloc] init];
    self.order.total = order.total;
    
    
    // encode data
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    [self httpPostRequestToUrl:[urls objectForKey:kSUBMIT_ORDER_URL] data:post];
    
    /*
     *
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.serverAddress,SUBMIT_ORDER_URL]]];
    
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
     */
}

/**
 *  Respond to read requests
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    //NSLog(@"Read Callback");
    if ([request.characteristic.UUID isEqual:self.transferCharacteristic.UUID]) {
        request.value = [self.transferCharacteristic.value subdataWithRange:NSMakeRange(request.offset, self.transferCharacteristic.value.length - request.offset)];
        
        
        NSLog(@"Read Callback Requested Value: %@",request.value);
        
        if (request.value==nil) {
            
            //sumbit order using http at load
            
            //data to post
            //NSString *post = [NSString stringWithFormat:@"&total=%@&customer_id=%@",[self.order getPrice:self.order.pizzaname],@"1"];
            
            //call http helper
            //[self httpPostRequestToUrl:[urls objectForKey:kSUBMIT_ORDER_URL] data:post];
            
            /*
             *
            NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverAddress,SUBMIT_ORDER_URL]]];
            
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
             *
             *
             *
             */
            
        }
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    }
    else if([request.characteristic.UUID isEqual:self.orderCharacteristic.UUID])
    {
        
        self.orderCharacteristic.value = [encrypter encryptWithAES: [self.orderId dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
        
        request.value = [self.orderCharacteristic.value subdataWithRange:NSMakeRange(request.offset, self.orderCharacteristic.value.length - request.offset)];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    }
    else if([request.characteristic.UUID isEqual:self.loyaltyCharacteristic.UUID])
    {
        NSLog(@"Read Callback Requested Value1: %@",request.value);
        request.value = [self.loyaltyCharacteristic.value subdataWithRange:NSMakeRange(request.offset, self.loyaltyCharacteristic.value.length - request.offset)];
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    }
    else if([request.characteristic.UUID isEqual:self.keyCharacteristic.UUID])
    {
        request.value = [self.keyCharacteristic.value subdataWithRange:NSMakeRange(request.offset, self.keyCharacteristic.value.length - request.offset)];
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    }
    else if([request.characteristic.UUID isEqual:self.paykeyCharacteristic.UUID])
    {
        request.value = [self.paykeyCharacteristic.value subdataWithRange:NSMakeRange(request.offset, self.paykeyCharacteristic.value.length - request.offset)];
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    }
    
}

/** 
 * Respond to write requests
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    
    CBATTRequest* request = [requests objectAtIndex:0];
    NSLog(@"Write Callback Method Invoked %@", [request.characteristic.UUID UUIDString]);
    
    if ([request.characteristic.UUID isEqual:self.transferNtfyCharacteristic.UUID]) {
        NSLog(@"Write Callback Request Recived %@",request.value);
        
        //create NSData expected
        const unsigned char bytes[] = {0x01,0x00};
        NSData* expected = [[NSData alloc] initWithBytes:bytes length:2];
        //NSLog(@"Expected Created %@",expected);
        if ([request.value isEqual:expected ])
        {
            
            NSLog(@"Write Callback Match Found %@",request.value);
            
            [self.subscribedCentrals addObject:request.central];
            
            
            NSLog(@"Write Callback Central Found %@",request.central);
            
        }else{
            self.total = [[NSString alloc] initWithData:[encrypter decryptWithAES:request.value key:encrypter.symmetricKey] encoding:NSASCIIStringEncoding];
            
            self.order = [[Order alloc] init];
            self.order.total = self.total;
            self.order.orderId = self.orderId;
            
            [delegate orderDetailsRecieved:self.order];
            
            /*
             * handle this in delegate
             *
             *
            //Set the UI;
            [self.spinner stopAnimating];
            [self.imageView setImage:[UIImage imageNamed:@"screen_4.png"]];
            
            UITextView *theText = [[UITextView alloc] initWithFrame:self.view.bounds];
            theText.frame = CGRectMake(112, 241, 100, 100);
            theText.backgroundColor = [UIColor clearColor];
            theText.text = self.total;
            
            [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:34]];
            theText.font = [UIFont boldSystemFontOfSize:34];
            
            [self.view addSubview:theText];
            
            theText = [[UITextView alloc] initWithFrame:self.view.bounds];
            theText.frame = CGRectMake(189, 282, 100, 100);
            theText.backgroundColor = [UIColor clearColor];
            theText.text = self.order_id;
            
            [theText setFont:[UIFont fontWithName:@"Roboto-Regular" size:34]];
            theText.font = [UIFont boldSystemFontOfSize:34];
            
            [self.view addSubview:theText];
            
            //set button to true
            [self.btnAcceptTransaction setEnabled:true];
            [self.btnDismissTransaction setEnabled:true];
            self.btnAcceptTransaction.hidden = false;
            self.btnDismissTransaction.hidden = false;
             
             */
            
        }
        [self.peripheralManager respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
        
    }
    else if([request.characteristic.UUID isEqual:self.confirmkeyCharacteristic.UUID])
    {
        //recieved the pay key now we need to verify it and reterive the detailed recpiet
        self.confirmKey = [[NSString alloc] initWithData:[encrypter decryptWithAES:request.value key:encrypter.symmetricKey] encoding:NSASCIIStringEncoding];
        
        //check confirm key
        //data to post
        NSString *post = [NSString stringWithFormat:@"&order_id=%@&confirm_key=%@",self.orderId ,self.confirmKey];
        
        //make http call
        [self httpPostRequestToUrl:[urls objectForKey:kVERIFY_URL] data:post];
        
        /*
         * handled with helper method
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.server_address,VERIFY_URL]]];
        
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
         */
        
        [self.peripheralManager respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
    }
    else if([request.characteristic.UUID isEqual:self.orderCharacteristic.UUID])
    {
        
        self.orderId =[[NSString alloc] initWithData:[encrypter decryptWithAES:request.value key:encrypter.symmetricKey] encoding:NSASCIIStringEncoding];
        self.orderCharacteristic.value = request.value;
        self.transferCharacteristic.value = request.value;
        
        
        
        
        [self.peripheralManager respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
        
       
    }
    else if ([request.characteristic.UUID isEqual:self.certficateCharacteristic.UUID]) {
        
        NSLog(@"Write Callback Request Recived %@",request.value);
        
        //create NSData expected
        const unsigned char bytes[] = {0x01,0x00};
        NSData* expected = [[NSData alloc] initWithBytes:bytes length:2];
        //NSLog(@"Expected Created %@",expected);
        if ([request.value isEqual:expected ])
        {
            
            // NSLog(@"Write Callback Match Found %@",request.value);
            [self.subscribedCentrals addObject:request.central];
            
            NSLog(@"Write Callback Central Found %@",request.central);
            
        }else{
            NSLog(@"Write Callback offest %lu",(unsigned long)request.offset);
            [self.publiccertificate appendData:request.value];
            
            if (self.publiccertificate.length >= 731) {
                [encrypter generateSymmetricKeyCertificate:self.publiccertificate];
                
                
                
                //update the values for charactersitics
                self.keyCharacteristic.value = [encrypter encryptWithRSA:encrypter.symmetricKey];
                
                if (self.orderpay) {
                    self.orderCharacteristic.value = [encrypter encryptWithAES:[@"0" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
                }
                else
                {
                    self.orderCharacteristic.value = [encrypter encryptWithAES:[@"1" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
                    
                }
                
                // set loyalty number
                self.loyaltyCharacteristic.value = [encrypter encryptWithAES:[@"777" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
                
                
                //notify the subsribed centrals
                [self.peripheralManager updateValue:self.keyCharacteristic.value forCharacteristic:self.keyCharacteristic onSubscribedCentrals:nil];
                
            }
        }
        [self.peripheralManager respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
        
    }else if([request.characteristic.UUID isEqual:self.keyCharacteristic.UUID]) {
        
        NSLog(@"Write Callback Request Recived %@",request.value);
        
        //create NSData expected
        const unsigned char bytes[] = {0x01,0x00};
        NSData* expected = [[NSData alloc] initWithBytes:bytes length:2];
        //NSLog(@"Expected Created %@",expected);
        if ([request.value isEqual:expected ])
        {
            
            // NSLog(@"Write Callback Match Found %@",request.value);
            [self.subscribedCentrals addObject:request.central];
            
            NSLog(@"Write Callback Central Found %@",request.central);
            
        }
    }
    
}



/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic%@",characteristic.UUID);
    
     if([characteristic.UUID isEqual:self.keyCharacteristic.UUID]) {
         [encrypter generateSymmetricKeyCertificate];
         
         
         
         //update the values for charactersitics
         self.keyCharacteristic.value = [encrypter encryptWithRSA:encrypter.symmetricKey];
         
         if (self.orderpay) {
             self.orderCharacteristic.value = [encrypter encryptWithAES:[@"0" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
         }
         else
         {
             self.orderCharacteristic.value = [encrypter encryptWithAES:[@"1" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
             
         }
         
         // set loyalty number
         self.loyaltyCharacteristic.value = [encrypter encryptWithAES:[@"777" dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
         
         
         //notify the subsribed centrals
         [self.peripheralManager updateValue:self.keyCharacteristic.value forCharacteristic:self.keyCharacteristic onSubscribedCentrals:nil];
    }
    
}


/**
 * Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    
}


/** 
 *  This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    // [self sendData];
    // [self.peripheralManager updateValue:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
}
/**
 * 
 */
- (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central
{
    [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral: central];
    NSLog(@"Sent: EOM");
}

#pragma http helper methods

-(NSURLConnection *) httpPostRequestToUrl:(NSURL *)url
                                   data:(NSString *)data{
    // data to post
    NSString *post = data;
    
    // encode data
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:url];
    
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
        NSString *domain = kHTTPERRORDOMAIN;
        NSString *desc = [[conn.currentRequest URL] relativeString];
        NSDictionary *userInfo = [[NSDictionary alloc]
                                  initWithObjectsAndKeys:desc,
                                  @"NSLocalizedDescriptionKey",NULL];
        
        
        NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                            userInfo:userInfo];
        
        [delegate reportError:errorPtr];
    }
    
    return conn;
}

-(void)cancelTransaction:(BOOL)transaction {
    if (!peripheralManager) {
        [self.peripheralManager updateValue:[@"d:s1" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.statusCharacteristic onSubscribedCentrals:nil];
        
        [self.peripheralManager stopAdvertising];
        transaction = true;
    }
    else
        transaction = false;
}
#pragma helpers

-(void)generateAndSubmitPayKey {
    //generate unique key string
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    
    self.payKey = uuidString;
    
    NSString *post = [NSString stringWithFormat:@"&order_id=%@&payment_key=%@",self.orderId ,self.payKey];
    
    [self httpPostRequestToUrl:[urls objectForKey:kCONFIRM_PAYMENT] data:post];
    
    NSLog(@"Payment Key : %@ order_id : %@", self.payKey, self.orderId);
    
}

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
    
    NSURL *tempurl = [connection.currentRequest URL];
    
    //if response from submitorder.php
    if ([tempurl isEqual:[urls objectForKey:kSUBMIT_ORDER_URL]]) {
        if([recievedata rangeOfString:@"Order Submitted :"].location!=NSNotFound)
        {
            
            //update the characteristics with order number
            self.orderId = [recievedata substringFromIndex:18];
           
            self.orderCharacteristic.value = [encrypter encryptWithAES: [self.orderId dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
            //[self.peripheralManager updateValue:[encrypter encryptWithAES:self.tempdata key:encrypter.symmetricKey] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
                self.toAdvertise = YES;
            }else{
                
                [self advertise];
            }
            
            self.order.orderId = self.orderId;
            
            [delegate orderRecieved:self.order];
            
            NSLog(@"Received HTTP Response %@",self.orderId );
            
        }
    }
    
    else if ([tempurl isEqual:[urls objectForKey:kCONFIRM_PAYMENT]])
    {
    
        
        if ([recievedata rangeOfString:@"Payment Key Update :"].location!=NSNotFound)
        {
        
            if([recievedata rangeOfString:@"Success"].location!=NSNotFound)
            {
                self.paykeyCharacteristic.value = [encrypter encryptWithAES:[self.payKey dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey];
                [self.peripheralManager updateValue:[encrypter encryptWithAES:[self.payKey dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey] forCharacteristic:self.paykeyCharacteristic onSubscribedCentrals:nil];
            }
            else
            {
                //self.alert.title = @"Something Went Wrong";
                NSString *domain = kPAYKEYUPDATEFAILEDERRORDOMAIN;
                NSString *desc = kPAYKEYUPDATEFAILEDERRORSTRING;
                NSDictionary *userInfo = [[NSDictionary alloc]
                                          initWithObjectsAndKeys:desc,
                                          @"NSLocalizedDescriptionKey",NULL];
                
                
                NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                                    userInfo:userInfo];
                
                [delegate reportError:errorPtr];
            }
        }
    }
    else if ([tempurl isEqual:[urls objectForKey:kVERIFY_URL]])
    {
        
     if ([recievedata rangeOfString:@"Confirm Key Check :"].location!=NSNotFound)
     {
        
        if([recievedata rangeOfString:@"Success"].location!=NSNotFound)
        {
            [self.peripheralManager updateValue:[encrypter encryptWithAES:[CONFIRMKEYMATCHEDCODE dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            [delegate transactionSuccessfull:self.order];
            
            /*
             *
             *
                // print the detailed reciept and update the view
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
             *
             *
             */
            
            [self.peripheralManager stopAdvertising];
        }
        else
        {
            //self.alert.title = @"Something Went Wrong";
            
            NSString *domain = kCONFIRMKEYMATCHFAILEDERRORDOMAIN;
            NSString *desc = kCONFIRMKEYMATCHFAILEDERRORSTRING;
            NSDictionary *userInfo = [[NSDictionary alloc]
                                      initWithObjectsAndKeys:desc,
                                      @"NSLocalizedDescriptionKey",NULL];
            
            
            NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                        userInfo:userInfo];
            
            [delegate reportError:errorPtr];
            
            [self.peripheralManager updateValue:[encrypter encryptWithAES:[CONFIRMKEYFAILEDCODE dataUsingEncoding:NSUTF8StringEncoding] key:encrypter.symmetricKey] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        }
    }
    }
    [_responseData appendData:data];
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
    NSString *domain = kHTTPERRORDOMAIN;
    NSString *desc = [[connection.currentRequest URL] relativeString];
    NSDictionary *userInfo = [[NSDictionary alloc]
                              initWithObjectsAndKeys:desc,
                              @"NSLocalizedDescriptionKey",NULL];
    
    
    NSError *errorPtr = [NSError errorWithDomain:domain code:-101
                                        userInfo:userInfo];
    
    [delegate reportError:errorPtr];
}




@end
