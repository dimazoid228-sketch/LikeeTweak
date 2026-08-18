#import <UIKit/UIKit.h>

__attribute__((constructor))
static void LikeeTweakLoaded(void) {
    
    NSLog(@"[LikeeTweak] DYLIB LOADED");

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

        if (!window) {
            NSLog(@"[LikeeTweak] NO WINDOW");
            return;
        }

        UIViewController *vc = window.rootViewController;

        while (vc.presentedViewController)
            vc = vc.presentedViewController;

        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"LikeeTweak"
                                                message:@"DYLIB загружен!"
                                         preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:nil]];

        [vc presentViewController:alert
                         animated:YES
                       completion:nil];

        NSLog(@"[LikeeTweak] ALERT SHOWN");
    });
}
