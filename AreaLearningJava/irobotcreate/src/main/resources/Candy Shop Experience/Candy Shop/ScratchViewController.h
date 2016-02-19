//
//  ScratchViewController.h
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScratchView.h"

@interface ScratchViewController : UIViewController
{
    NSInteger _availableCredits;
}


@property (nonatomic, strong) IBOutlet ScratchView *scratchView;
@property (nonatomic, strong) IBOutlet UILabel *instructionLabel;

@end
