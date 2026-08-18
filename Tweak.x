#import <UIKit/UIKit.h>

@interface LikeeTweakTest : NSObject
@property (nonatomic, strong) UIButton *button;
+ (instancetype)sharedInstance;
- (void)installButton;
- (void)buttonTapped:(UIButton *)sender;
@end

@implementation LikeeTweakTest

+ (instancetype)sharedInstance {
    static LikeeTweakTest *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[LikeeTweakTest alloc] init];
    });

    return instance;
}

- (void)installButton {

    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.button != nil) {
            return;
        }

        UIWindow *window = nil;

        if (@available(iOS 13.0, *)) {

            for (UIScene *scene in
                 UIApplication.sharedApplication.connectedScenes) {

                if (scene.activationState !=
                    UISceneActivationStateForegroundActive) {
                    continue;
                }

                if (![scene isKindOfClass:[UIWindowScene class]]) {
                    continue;
                }

                for (UIWindow *candidate in
                     ((UIWindowScene *)scene).windows) {

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

        UIButton *button =
            [UIButton buttonWithType:UIButtonTypeSystem];

        button.frame = CGRectMake(
            window.bounds.size.width - 70.0,
            window.bounds.size.height / 2.0 - 25.0,
            50.0,
            50.0
        );

        [button setTitle:@"LT"
                forState:UIControlStateNormal];

        [button setTitleColor:UIColor.whiteColor
                      forState:UIControlStateNormal];

        button.backgroundColor =
            [UIColor colorWithWhite:0.0 alpha:0.80];

        button.layer.cornerRadius = 25.0;
        button.layer.masksToBounds = YES;

        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];

        [window addSubview:button];

        self.button = button;

        NSLog(@"[LikeeTweak] BUTTON INSTALLED");
    });
}

- (void)buttonTapped:(UIButton *)sender {

    UIAlertController *alert =
        [UIAlertController
            alertControllerWithTitle:@"LikeeTweak"
                             message:@"Тестовая кнопка работает!"
                      preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:
        [UIAlertAction
            actionWithTitle:@"OK"
                     style:UIAlertActionStyleDefault
                   handler:nil]];

    UIViewController *controller =
        UIApplication.sharedApplication.keyWindow.rootViewController;

    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }

    [controller presentViewController:alert
                             animated:YES
                           completion:nil];
}

@end


%ctor {

    NSLog(@"[LikeeTweak] CONSTRUCTOR");

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW,
                      3 * NSEC_PER_SEC),
        dispatch_get_main_queue(),
        ^{
            [[LikeeTweakTest sharedInstance] installButton];
        }
    );
}
