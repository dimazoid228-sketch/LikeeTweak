#import <UIKit/UIKit.h>

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    NSLog(@"[LikeeTweak] LOADED");
}

%end
