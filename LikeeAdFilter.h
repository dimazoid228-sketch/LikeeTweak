#import <UIKit/UIKit.h>

@interface LikeeAdFilter : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;
- (void)scan;

@end
