#import <UIKit/UIKit.h>

@interface LikeeTweakMenu : NSObject

@property (nonatomic, strong) UIButton *button;

+ (instancetype)sharedMenu;
- (void)showButton;
- (void)buttonPressed:(UIButton *)sender;

@end

@implementation LikeeTweakMenu

+ (instancetype)sharedMenu {
    static LikeeTweakMenu *menu;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        menu = [[LikeeTweakMenu alloc] init];
    });

    return menu;
}

- (void)showButton {

    if (self.button != nil) {
        return;
    }

    UIWindow *window = nil;

    if (@available(iOS 13.0, *)) {

        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {

            if (scene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }

            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }

            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {

                if (candidate.isKeyWindow) {
                    window = candidate;
                    break;
                }
            }

            if (window != nil) {
                break;
            }
        }
    }

    if (window == nil) {
        window = UIApplication.sharedApplication.keyWindow;
    }

    if (window == nil) {
        NSLog(@"[LikeeTweak] Window not found");
        return;
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

    button.frame = CGRectMake(
        window.bounds.size.width - 65.0,
        window.bounds.size.height / 2.0 - 25.0,
        50.0,
        50.0
    );

    [button setTitle:@"LT" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];

    button.backgroundColor =
        [UIColor colorWithWhite:0.0 alpha:0.75];

    button.layer.cornerRadius = 25.0;
    button.layer.masksToBounds = YES;

    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];

    [window addSubview:button];

    self.button = button;

    NSLog(@"[LikeeTweak] Floating button loaded");
}

- (void)buttonPressed:(UIButton *)sender {

    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"LikeeTweak"
                                            message:@"Меню твика работает!"
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil]];

    UIViewController *rootViewController =
        UIApplication.sharedApplication.keyWindow.rootViewController;

    if (rootViewController != nil) {

        [rootViewController presentViewController:alert
                                         animated:YES
                                       completion:nil];
    }
}

@end


%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {

    %orig;

    dispatch_async(dispatch_get_main_queue(), ^{

        [[LikeeTweakMenu sharedMenu] showButton];

    });
}

%end
