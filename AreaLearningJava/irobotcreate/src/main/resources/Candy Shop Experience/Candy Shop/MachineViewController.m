//
//  MachineViewController.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "MachineViewController.h"
#import "EmailViewController.h"
#import "CompleteViewController.h"
#import "PaySelectionViewController.h"
#import "Order.h"

#define kSlotLabelTag 1
#define kProductImageTag 2
#define kPointsImageTag 3


@interface MachineViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@end

@implementation MachineViewController

@synthesize leftBarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.leftBarButtonItem setImage:[self.leftBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    NSDictionary *theDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"prizes" ofType:@"plist"]];
    _prizes = [theDict objectForKey:@"prizes"];
    
    UIImageView *navTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select-nav-title"]];
    self.navigationItem.titleView = navTitleView;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"point-balance-background"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    backgroundImageView.frame = CGRectMake(CENTER_HORIZONTALLY(headerView, backgroundImageView), 0, WIDTH(backgroundImageView), HEIGHT(backgroundImageView));
    [headerView addSubview:backgroundImageView];
    
    UIImage *pointsImage = [UIImage imageNamed:@"point-balance-1000"];
    _balanceImageView = [[UIImageView alloc] initWithImage:pointsImage];
    _balanceImageView.frame = CGRectMake(WIDTH(headerView) - WIDTH(_balanceImageView) - 30,
                                         CENTER_VERTICALLY(headerView, _balanceImageView),
                                         WIDTH(_balanceImageView), HEIGHT(_balanceImageView));
    [headerView addSubview:_balanceImageView];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.availableCredits == 500)
    {
        _balanceImageView.image = [UIImage imageNamed:@"point-balance-500"];
    }
    else
    {
        _balanceImageView.image = [UIImage imageNamed:@"point-balance-1000"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSNumber *columnNumber = [_selectedPrizeInfo objectForKey:@"column"];
    NSString *vendingMessage = [NSString stringWithFormat:@"%@%02d", _selectedRowName, [columnNumber integerValue]];
    vendingMessage = [vendingMessage lowercaseString];

    if (![segue.identifier isEqualToString:@"eventmode"]){
        EmailViewController *emailViewController = [segue destinationViewController];
        emailViewController.vendingMessage = vendingMessage;
        emailViewController.prizeInfo = _selectedPrizeInfo;
        emailViewController.rowName = _selectedRowName;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_prizes count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shelf" forIndexPath:indexPath];
    
    //hack set the tag of the collection view to indicate which row of the table this is for
    //big misuse of tags but time only permits this
    //good article on use of tags http://doing-it-wrong.mikeweller.com/2012/08/youre-doing-it-wrong-4-uiview.html
    
    //find the collection view in the contentView subviews
    for(UIView *subview in cell.contentView.subviews)
    {
        if([subview isKindOfClass:[UICollectionView class]])
        {
            NSInteger oldTag = subview.tag;
            subview.tag = indexPath.row;
            if(oldTag!= indexPath.row)
            {
                UICollectionView *collectionView = (UICollectionView *)subview;
                [collectionView reloadData];
            }
            
        }
    }
    
    return cell;
}



#pragma mark - UITableViewDelegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIImage *backgroundImage = [UIImage imageNamed:@"point-balance-background"];
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//    backgroundImageView.frame = CGRectMake(CENTER_HORIZONTALLY(headerView, backgroundImageView), 0, WIDTH(backgroundImageView), HEIGHT(backgroundImageView));
//    [headerView addSubview:backgroundImageView];
//    
//    return headerView;
//}



#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    //find which row this is for
    NSInteger tableRow = view.tag;
    NSDictionary *rowInfo = [_prizes objectAtIndex:tableRow];
    NSArray *rowItems = [rowInfo objectForKey:@"items"];
    return [rowItems count];
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"product" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor colorWithRed:0.1f green:0.4f blue:0.7f alpha:0.6f];
    
    
    //get info for the prize for this cell
    NSInteger tableRow = cv.tag;
    NSDictionary *rowInfo = [_prizes objectAtIndex:tableRow];
    NSArray *rowItems = [rowInfo objectForKey:@"items"];
    
    NSDictionary *prizeInfo = [rowItems objectAtIndex:indexPath.row];
    NSString *rowName = [rowInfo objectForKey:@"row"];
    UILabel *slotLabel = (UILabel *)[cell.contentView viewWithTag:kSlotLabelTag];
//    slotLabel.font = [UIFont fontWithName:@"AkzidenzGroteskBE-LightCn" size:22.0f];
    slotLabel.text = [NSString stringWithFormat:@"%@%d", rowName, indexPath.row+1];
    
    NSString *soldoutSlots = [[NSUserDefaults standardUserDefaults] objectForKey:@"soldout"];
    
    if ([soldoutSlots.lowercaseString rangeOfString:slotLabel.text.lowercaseString].location == NSNotFound) {
        NSString *prizeImageName = [prizeInfo objectForKey:@"image"];
        UIImage *prizeImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-big", prizeImageName]];
        UIImageView *prizeImageView = (UIImageView *)[cell.contentView viewWithTag:kProductImageTag];
        prizeImageView.image = prizeImage;
        
        NSNumber *prizePoints = [prizeInfo objectForKey:@"points"];
        UIImage *pointsImage = nil;
        if([prizePoints integerValue] == 500)
        {
            pointsImage = [UIImage imageNamed:@"points-500"];
        }
        else if([prizePoints integerValue] == 1000)
        {
            pointsImage = [UIImage imageNamed:@"points-1000"];
        }
        else
        {
            pointsImage = nil;
        }
        
        UIImageView *pointsImageView = (UIImageView *)[cell.contentView viewWithTag:kPointsImageTag];
        if(pointsImage)
        {
            pointsImageView.hidden = NO;
            pointsImageView.image = pointsImage;
        }
        else
        {
            pointsImageView.hidden = YES;
        }
    } else {
        UIImage *prizeImage = [UIImage imageNamed:@"sorry-not-enough-points-big"];
        UIImageView *prizeImageView = (UIImageView *)[cell.contentView viewWithTag:kProductImageTag];
        prizeImageView.image = prizeImage;
        
        UIImageView *pointsImageView = (UIImageView *)[cell.contentView viewWithTag:kPointsImageTag];
        pointsImageView.hidden = YES;
    }
    
    return cell;
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/



#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSInteger tableRow = collectionView.tag;
    NSDictionary *rowInfo = [_prizes objectAtIndex:tableRow];
    NSArray *rowItems = [rowInfo objectForKey:@"items"];
    
    NSDictionary *prizeInfo = [rowItems objectAtIndex:indexPath.row];
    NSString *rowName = [rowInfo objectForKey:@"row"];
    
    //see if there are enough credits available for given prize
    NSNumber *prizeValue = [prizeInfo objectForKey:@"points"];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *pointsImageView = (UIImageView *)[cell.contentView viewWithTag:kPointsImageTag];

    if(!pointsImageView.hidden && [prizeValue integerValue] > 0)
    {
        if(self.availableCredits < [prizeValue integerValue])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not enough points"
                                                                message:@"Please select another prize"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alertView show];
        }
        else
        {
            _selectedPrizeInfo = prizeInfo;
            _selectedRowName = rowName;
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"eventmode"]){
                [self performSegueWithIdentifier:@"email" sender:self];
            }
        }
    }
    
    return false;
}

#pragma mark - Button Handlers
- (IBAction)leftBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(173.0f, 133.0f);
//}

// 3
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


@end
