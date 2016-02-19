//
//  EmailViewController.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-07.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "EmailViewController.h"
#import "Emails.h"
#import "CompleteViewController.h"

@interface EmailViewController()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@end

@implementation EmailViewController

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

    [self.leftBarButtonItem setImage:[self.leftBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email-nav-title"]];
    self.navigationItem.titleView = navTitleView;
    
    
    self.prizeNameLabel.font = [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:30.0f];
    self.prizeNameLabel.text = [self.prizeInfo objectForKey:@"name"];
    [self.prizeNameLabel.text uppercaseString];
    
    self.pointsLabel.font = [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:30.0f];
    NSNumber *prizePoints = [self.prizeInfo objectForKey:@"points"];
    self.pointsLabel.text =  [NSString stringWithFormat:@"%d PTS", [prizePoints integerValue]];
    
    NSString *prizeImageName = [self.prizeInfo objectForKey:@"image"];
    UIImage *prizeImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-big", prizeImageName]];
    self.prizeImageView.image = prizeImage;
    
    self.emailLabel.font = [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:24.0f];
    
    UIView *indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.emailField.leftView = indentView;
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    
    
    indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.nameField.leftView = indentView;
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
 
  
}

- (void)viewDidAppear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"email"]) {
        [self performSegueWithIdentifier:@"complete" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handleSingleTap:(id)sender
{
    [self.nameField resignFirstResponder];
    [self.emailField resignFirstResponder];
}


- (IBAction)textFieldChanged:(id)sender
{
    if([self.emailField.text length] >= 4 && [self.nameField.text length] >= 3)
    {
        self.doneButton.enabled = YES;
    }
    else
    {
        self.doneButton.enabled = NO;
    }
}

- (IBAction)donePressed:(id)sender
{
    [self getCandy];
}


- (void)getCandy
{
    if([self.emailField.text length] >= 4 && [self.nameField.text length] >= 3)
    {
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        Emails *email = [Emails MR_createInContext:localContext];
        email.email = self.emailField.text;
        email.name = self.nameField.text;
        [localContext MR_saveToPersistentStoreAndWait];
        
        [self performSegueWithIdentifier:@"complete" sender:self];
    }
}


- (void)returnHome
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.emailField resignFirstResponder];
    [self.nameField resignFirstResponder];
    CompleteViewController *completeController = (CompleteViewController *)[segue destinationViewController];
    completeController.vendingMessage = self.vendingMessage;
}


#pragma mark - notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    NSNumber *animationCurve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    //move this view controller up by the height of the keyboard
    [UIView animateWithDuration:[animationDuration doubleValue]
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         MOVE_TO_Y(self.view, -1 * kbSize.height);
                     } completion:^(BOOL finished) {
                         
                     }];

    
}



- (void)keyboardWillBeHidden:(NSNotification *)notification
{

    NSDictionary* info = [notification userInfo];
    NSNumber *animationDuration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    //move this view controller up by the height of the keyboard
    [UIView animateWithDuration:[animationDuration doubleValue]
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         MOVE_TO_Y(self.view, 0.0f);
                     } completion:^(BOOL finished) {
                         
                     }];
    
}


#pragma mark - UITextFieldDelegate



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.nameField)
    {
        [self.emailField becomeFirstResponder];
    }
    else
    {
        //check that there is info in each field
        [self getCandy];
    }
    return YES;
}

#pragma mark - Button Handlers
- (IBAction)leftBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
