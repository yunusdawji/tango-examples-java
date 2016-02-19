//
//  BearActivityIndicatorView.m
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-09-15.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import "BearActivityIndicatorView.h"

#define kNumberOfBears 8
#define kDimension 3
#define kAnimationSpeed 0.50

@interface BearActivityIndicatorView()

@property (strong,nonatomic) NSMutableArray *arrayOfBears;
@property (assign,nonatomic) float currentIndex;
@property (strong,nonatomic) NSTimer *animationTimer;

@end

@implementation BearActivityIndicatorView

@synthesize arrayOfBears;
@synthesize currentIndex;
@synthesize animationTimer;

- (id)init
{
 
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingBear1"]];
    
    /* Places bears in a circle
    float indicatorHeight = kDimension * tempImageView.frame.size.height;
    float indicatorWidth = kDimension * tempImageView.frame.size.width;
    */
    
    float indicatorHeight =tempImageView.frame.size.height;
    float indicatorWidth =tempImageView.frame.size.width;

    
    CGRect frame = CGRectMake(0, 0, indicatorWidth, indicatorHeight);
    self = [super initWithFrame:frame];
    if (self) {
        
        arrayOfBears = [[NSMutableArray alloc] initWithCapacity:kNumberOfBears];
        for (int i = 0; i < kNumberOfBears; i++){
            UIImage *bearImage = [UIImage imageNamed:[NSString stringWithFormat:@"loadingBear%d",i]];
            UIImageView *bearImageView = [[UIImageView alloc] initWithImage:bearImage];
            
            
            // Hide every bear except for one
            if (i != 0){
                [bearImageView setAlpha:0];
            }
            
            [arrayOfBears addObject:bearImageView];
            [self addSubview:bearImageView];
        }
        
        
        /* Places bears in a circle
        int column = 0;
        int row = 0;
        currentIndex = 0;
        
        for (int i = 0; i < kNumberOfBears; i++){

            UIImage *bearImage = [UIImage imageNamed:[NSString stringWithFormat:@"loadingBear%d",i]];
            UIImageView *bearImageView = [[UIImageView alloc] initWithImage:bearImage];
            
            // Hide every bear except for one
            if (i != 0){
                [bearImageView setAlpha:0];
            }
            
            // Bears are placed side by side in a 3 x 3 grid
            [bearImageView setFrame:CGRectMake(column * bearImageView.frame.size.width, row * bearImageView.frame.size.height, bearImageView.frame.size.width, bearImageView.frame.size.height)];
            
            [arrayOfBears addObject:bearImageView];
            [self addSubview:bearImageView];
            
            // Top Row
            if (row == 0 && column < 2){
                column ++;
            }
            
            // Right column
            else if (column ==2 && row < 2){
                row ++;
            }
            
            // Bottom row
            else if (column > 0 && row == 2){
                column --;
            }
            
            // Left column
            else if (column == 0 && row == 2) {
                row --;
            }
        }
         */
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:kAnimationSpeed + 0.05 target:self selector:@selector(incrementLoader) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)removeLoader{
    [animationTimer invalidate];
    [self removeFromSuperview];
}

- (void)incrementLoader {

    dispatch_async(dispatch_get_main_queue(), ^{
        
        
    [UIView animateWithDuration:kAnimationSpeed delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        float fadeOutIndex;
        float fadeOutPartiallyIndex;
        float fadeInIndex;
        
        if (currentIndex == 0){
            fadeOutIndex = (kNumberOfBears - 1);
            fadeOutPartiallyIndex = currentIndex;
            fadeInIndex = currentIndex + 1;
        }
        
        else if (currentIndex == kNumberOfBears - 1){
            fadeOutIndex = currentIndex - 1;
            fadeOutPartiallyIndex = currentIndex;
            fadeInIndex = 0;
        }
        
        else {
            fadeOutIndex = currentIndex - 1;
            fadeOutPartiallyIndex = currentIndex;
            fadeInIndex = currentIndex + 1;
        }
        
        [[arrayOfBears objectAtIndex:fadeOutIndex] setAlpha:0];
        
        [[arrayOfBears objectAtIndex:fadeOutPartiallyIndex] setAlpha:0.0];
        
        [[arrayOfBears objectAtIndex:fadeInIndex] setAlpha:1];


        
    } completion:^(BOOL finished) {
        
        if (currentIndex >= kNumberOfBears - 1){
            currentIndex = 0;
        }else {
            currentIndex = currentIndex + 1;
        }
    }];
    
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
