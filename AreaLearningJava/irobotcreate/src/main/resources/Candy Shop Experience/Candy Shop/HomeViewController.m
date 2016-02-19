//
//  HomeViewController.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.statusLabel.text = nil;
    self.startButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ready:) name:kNotificationReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagFound:) name:kNotificationTagFound object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagLost:) name:kNotificationTagLost object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];

    [self ready:nil];
}

- (void)ready:(NSNotification *)notification {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ble"]) {
        self.statusLabel.text = @"Please hold the device with the hand with tag to activate.";
        self.startButton.hidden = YES;
        [self.activityIndicator startAnimating];
    } else {
        self.statusLabel.text = nil;
        self.startButton.hidden = NO;
    }
}

- (void)tagFound:(NSNotification *)notification {
    
    self.statusLabel.text = [NSString stringWithFormat:@"Hello %@", notification.object];
    self.startButton.hidden = NO;
    [self.activityIndicator stopAnimating];
}

- (void)tagLost:(NSNotification *)notification {

    [self ready:notification];
}

@end
