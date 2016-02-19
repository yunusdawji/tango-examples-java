//
//  BearActivityIndicatorView.h
//  Candy Shop
//
//  Created by Jeffrey Deng on 2014-09-15.
//  Copyright (c) 2014 Plastic Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

// Add this view to have a spinning bear activity indicator.
// Use remove loader to properly dismiss the view
@interface BearActivityIndicatorView : UIView

- (id)init;

-(void)removeLoader;

@end
