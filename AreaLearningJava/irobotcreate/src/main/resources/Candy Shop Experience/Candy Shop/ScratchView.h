//
//  ScratchView.h
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DealViewController;
@interface ScratchView : UIView
{
	CGPoint _lastPoint;
	UIImageView *_coverImageView;
    UIImage *_coverImage;
	BOOL _isMouseSwiped;
	int _mouseMoved;
	CGImageRef _maskRef;
}

@property (nonatomic, strong) UIImage *couponImage;


-(id)initWithFrame:(CGRect)rect coverImage:(UIImage *)coverImage couponImage:(UIImage*)couponImage;


- (void)configureCoverImage:(UIImage *)coverImage andCouponImage:(UIImage *)couponImage;

- (void)resetScratch;

@end
