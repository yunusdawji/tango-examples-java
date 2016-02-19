
#import <Foundation/Foundation.h>

@interface Order : NSObject
@property (nonatomic,readwrite) NSString    *pizzaname;
@property (nonatomic,readwrite) NSDictionary *prices;
@property (nonatomic,readwrite) NSString    *total;
@property (nonatomic,readwrite) NSString    *orderId;

-(NSString *) getPrice: (NSString *)input;


@end
