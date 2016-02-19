//
//  CompleteViewController.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-07.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "CompleteViewController.h"
#import "AppDelegate.h"
#import "SVProgressHud.h"
#import "AFHTTPRequestOperation.h"

@interface CompleteViewController ()

@end

@implementation CompleteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = nil;
    
    if (self.vendingMessage) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wifi"]) {
            NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/index.php?selection=%@", server, self.vendingMessage]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //                NSLog(@"Success");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //                NSLog(@"Fail");
            }];
            
            
            [operation start];
        } else {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate sendMessage:self.vendingMessage];
        }
    }
}

- (IBAction)donePressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
