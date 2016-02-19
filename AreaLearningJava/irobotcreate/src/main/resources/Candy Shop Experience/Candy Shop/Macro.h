//
//  Macro.h
//  Beyond The Rack
//
//  Created by Ryan McDonald on 2012-11-16.
//  Copyright (c) 2012 Plastic Mobile. All rights reserved.
//


#define iPad                    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


#pragma mark - Fonts

#define TYPEWRITER_FONT(s) [UIFont fontWithName:@"AmericanTypewriter" size:s]
#define TYPEWRITER_BOLDFONT(s) [UIFont fontWithName:@"AmericanTypewriter-Bold" size:s]

#define TrebuchetMS_FONT(s) [UIFont fontWithName:@"TrebuchetMS" size:s]
#define TrebuchetMS_MEDIUMFONT(s) ([UIFont fontWithName:@"TrebuchetMS-Medium" size:s] != nil ? \
[UIFont fontWithName:@"TrebuchetMS-Medium" size:s]: \
[UIFont fontWithName:@"TrebuchetMS-Bold" size:s])
#define TrebuchetMS_LIGHTFONT(s) ([UIFont fontWithName:@"TrebuchetMS-Light" size:s] != nil ? \
[UIFont fontWithName:@"TrebuchetMS-Light" size:s]: \
[UIFont fontWithName:@"TrebuchetMS" size:s])
#define TrebuchetMS_BOLDFONT(s) [UIFont fontWithName:@"TrebuchetMS-Bold" size:s]
#define HELVETICA_FONT(s) [UIFont fontWithName:@"Helvetica" size:s]
#define HELVETICA_BOLDFONT(s) [UIFont fontWithName:@"Helvetica-Bold" size:s]


#pragma mark - Frame Geometry

#define CENTER_VERTICALLY(parent,child)     floor((parent.frame.size.height - child.frame.size.height) / 2)
#define CENTER_HORIZONTALLY(parent,child)   floor((parent.frame.size.width - child.frame.size.width) / 2)
#define WIDTH(view)                     view.frame.size.width
#define HEIGHT(view)                    view.frame.size.height
#define X(view)                         view.frame.origin.x
#define Y(view)                         view.frame.origin.y
#define LEFT(view)                      view.frame.origin.x
#define TOP(view)                       view.frame.origin.y
#define BOTTOM(view)                    view.frame.origin.y + view.frame.size.height
#define RIGHT(view)                     view.frame.origin.x + view.frame.size.width
#define MOVE_TO_Y(view, y)      view.frame = CGRectMake(X(view), y, WIDTH(view), HEIGHT(view))
#define MOVE_TO_X(view, x)      view.frame = CGRectMake(x, Y(view), WIDTH(view), HEIGHT(view))
#define ADD_TO_X(view, x)       view.frame = CGRectMake(X(view) + x, Y(view), WIDTH(view), HEIGHT(view))
#define ADD_TO_Y(view, y)       view.frame = CGRectMake(X(view), Y(view) + y, WIDTH(view), HEIGHT(view))

#pragma mark - Convert

#define INT_TO_STR(int) [NSString stringWithFormat:@"%d", int]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define IS_NATIVE_TWITTER (NSClassFromString(@"TWTweetComposeViewController") != nil)



// iBeacon Advertising UUID
#define BROADCAST_UUID @"5E0960C3-A179-4330-99B8-61190ED7E105"
#define REGION_ID @"com.plastic.advertisment"


// Broadcasted UDIDs for the ad
#define PERSON_SERVICE_INFO_UUID            @"C6243480-CAAB-4196-BB41-77431FDD7697"
#define PERSON_CHARACTERISTIC_NAME_UUID     @"0A2F0E8F-C06C-4932-90C5-ADE7BD9C0D90"

// Peripheral Manager Restoration ID
#define RESTORATION_ID                      @"airmilesPeripheralRestorationID"

