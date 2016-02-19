//
//  MachineViewController.h
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MachineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSArray *_prizes;
    NSDictionary *_selectedPrizeInfo;
    NSString *_selectedRowName;
    UIImageView *_balanceImageView;
}

@property (nonatomic, assign) NSInteger availableCredits;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
