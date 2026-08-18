#import <UIKit/UIKit.h>

@interface LikeeTweakTest : NSObject
+ (void)showTest;
@end

@implementation LikeeTweakTest

+ (void)showTest {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;

        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
                
                if (scene.activationState != UISceneActivationStateForegroundActive)
                    continue;
                
                if (![scene isKindOfClass:[UIWindowScene class]])
                    continue;
                
                for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                    if (candidate.isKeyWindow) {
                        window = candidate;
                        break;
                    }
                }
                
                if (window)
                    break;
            }
        }

        if (!window)
            window = UIApplication.sharedApplication.keyWindow;

        if (!window)
            return;

        UIViewController *vc = window.rootViewController;

        while (vc.presentedViewController)
            vc = vc.presentedViewController;

        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"LikeeTweak"
                                                message:@"Твик реально загрузился!"
                                         preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:nil]];

        [vc presentViewController:alert animated:YES completion:nil];

        NSLog(@"[LikeeTweak] TEST SUCCESS");
    });
}

@end


%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;

    static BOOL alreadyShown = NO;

    if (!alreadyShown) {
        alreadyShown = YES;

        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
            dispatch_get_main_queue(), ^{
                [LikeeTweakTest showTest];
            }
        );
    }
}

%end
