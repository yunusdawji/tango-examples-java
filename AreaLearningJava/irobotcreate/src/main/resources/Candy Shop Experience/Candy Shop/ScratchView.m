//
//  ScratchView.m
//  Candy Shop
//
//  Created by Ryan McDonald on 2013-05-06.
//  Copyright (c) 2013 Plastic Mobile. All rights reserved.
//

#import "ScratchView.h"


#define MASK_IMAGE_NAME @"fingerprint-brush.png"
#define MASK_IMAGE_WIDTH 30.0f
#define MASK_IMAGE_HEIGHT 42.0f

@interface ScratchView (Private)
-(void)drawStrokeAtPoint:(CGPoint)point;
-(CGImageRef)newMaskWithImage:(CGImageRef)image;
-(void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
@end



@implementation ScratchView

-(id)initWithFrame:(CGRect)rect coverImage:(UIImage *)coverImage couponImage:(UIImage*)couponImage
{
    if ((self = [super initWithFrame:rect]))
	{
		self.couponImage = couponImage;
		_coverImage = coverImage;
		_coverImageView = [[UIImageView alloc] initWithImage:coverImage];
		[self addSubview:_coverImageView];
		self.backgroundColor = [UIColor clearColor];
		
		UIImage *maskImage = [UIImage imageNamed:MASK_IMAGE_NAME];
		_maskRef = [self newMaskWithImage:maskImage.CGImage];
		
		_mouseMoved = 0;
    }
	
    return self;
}



- (void)configureCoverImage:(UIImage *)coverImage andCouponImage:(UIImage *)couponImage;
{
    self.couponImage = couponImage;
    _coverImage = coverImage;
    _coverImageView = [[UIImageView alloc] initWithImage:coverImage];
    [self addSubview:_coverImageView];
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *maskImage = [UIImage imageNamed:MASK_IMAGE_NAME];
    _maskRef = [self newMaskWithImage:maskImage.CGImage];
    
    _mouseMoved = 0;
}



- (CGSize)sizeThatFits:(CGSize)size
{
    return _coverImage.size;
}

- (void)resetScratch
{
    _coverImageView.image = _coverImage;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_isMouseSwiped = NO;
	UITouch *touch = [touches anyObject];
	
	_lastPoint = [touch locationInView:self];
	_lastPoint.y -= 20;
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	_isMouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];
	CGPoint currentPoint = [touch locationInView:self];
	currentPoint.y -= 10;
	
	
	[self renderLineFromPoint:_lastPoint toPoint:currentPoint];
	
	
	_lastPoint = currentPoint;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
    if ([touch tapCount] == 2)
    {
        _coverImageView.image = _coverImage;
        return;
    }
	
	CGPoint currentPoint = [touch locationInView:self];
	currentPoint.y -= 10;
	
	[self renderLineFromPoint:_lastPoint toPoint:currentPoint];
}



- (void)didReceiveMemoryWarning
{
	
}




#pragma mark -
#pragma mark  Privae Methods

-(void)drawStrokeAtPoint:(CGPoint)point
{
	UIGraphicsBeginImageContext(self.frame.size);
	[_coverImageView.image drawInRect:CGRectMake(0, 0, _couponImage.size.width, _couponImage.size.height)];
    CGContextClipToMask(UIGraphicsGetCurrentContext(), CGRectMake(point.x, point.y, MASK_IMAGE_WIDTH, MASK_IMAGE_HEIGHT), _maskRef);
    [_couponImage drawInRect:CGRectMake(0, 0, _couponImage.size.width, _couponImage.size.height)];
	_coverImageView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}



-(CGImageRef) newMaskWithImage:(CGImageRef) image
{
    int maskWidth               = CGImageGetWidth(image);
    int maskHeight              = CGImageGetHeight(image);
    //  round bytesPerRow to the nearest 16 bytes, for performance's sake
    int bytesPerRow             = (maskWidth + 15) & 0xfffffff0;
    int bufferSize              = bytesPerRow * maskHeight;
	
    //  allocate memory for the bits
    CFMutableDataRef dataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(dataBuffer, bufferSize);
	
    //  the data will be 8 bits per pixel, no alpha
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
	
	CGContextRef ctx            = CGBitmapContextCreate(CFDataGetMutableBytePtr(dataBuffer),
                                                        maskWidth, maskHeight,
                                                        8, bytesPerRow, colourSpace, kCGImageAlphaNone);
    //  drawing into this context will draw into the dataBuffer.
    
	CGContextDrawImage(ctx, CGRectMake(0, 0, maskWidth, maskHeight), image);
	
	CGContextRelease(ctx);
	
    //  now make a mask from the data.
    CGDataProviderRef dataProvider  = CGDataProviderCreateWithCFData(dataBuffer);
    
	
	CGImageRef mask                 = CGImageMaskCreate(maskWidth, maskHeight, 8, 8, bytesPerRow,
                                                        dataProvider, NULL, FALSE);
	
	
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colourSpace);
    CFRelease(dataBuffer);
    
    return mask;
}


- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
	float count;
	NSInteger i;
	
	
	float scale = 1.0;
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
	
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / 32), 1);
	for(i = 0; i < count; ++i)
	{
		CGPoint tempPoint = CGPointMake( (start.x + (end.x - start.x) * (i /count)) , (start.y + (end.y - start.y) * (i /count)));
		[self drawStrokeAtPoint:tempPoint];
	}
}



@end
