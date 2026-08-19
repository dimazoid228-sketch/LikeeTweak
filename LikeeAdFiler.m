#import "LikeeAdFilter.h"

@interface LikeeAdFilter ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LikeeAdFilter

+ (instancetype)sharedInstance
{
    static LikeeAdFilter *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[LikeeAdFilter alloc] init];
    });

    return instance;
}

- (void)start
{
    [self stop];

    dispatch_async(dispatch_get_main_queue(), ^{

        [self scan];

        self.timer =
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(scan)
                                       userInfo:nil
                                        repeats:YES];

        NSLog(@"[LikeeAdFilter] started");
    });
}

- (void)stop
{
    if (self.timer != nil) {

        [self.timer invalidate];
        self.timer = nil;

        NSLog(@"[LikeeAdFilter] stopped");
    }
}

- (void)scan
{
    if (!NSThread.isMainThread) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self scan];
        });

        return;
    }

    BOOL enabled =
    [[NSUserDefaults standardUserDefaults]
        boolForKey:@"LikeeTweakAdFilter"];

    if (!enabled) {
        return;
    }

    /*
     * Рекламные UI-классы, которые уже нашли.
     */

    Class adCard =
    NSClassFromString(@"BVVideoDetailAdCardView");

    Class adStyle =
    NSClassFromString(
        @"LIKE.BVVideoDetailAdStyle1CardView"
    );

    /*
     * Moloco.
     *
     * Здесь специально проверяем именно VideoPlayerUIView,
     * а не весь SDK целиком.
     */

    Class moloco =
    NSClassFromString(@"MolocoSDK.VideoPlayerUIView");

    for (UIWindow *window
         in UIApplication.sharedApplication.windows) {

        if (adCard != Nil) {
            [self scanView:window
                   adClass:adCard];
        }

        if (adStyle != Nil) {
            [self scanView:window
                   adClass:adStyle];
        }

        if (moloco != Nil) {
            [self scanView:window
                   adClass:moloco];
        }
    }
}

- (void)scanView:(UIView *)view
         adClass:(Class)adClass
{
    if (view == nil || adClass == Nil) {
        return;
    }

    if ([view isKindOfClass:adClass]) {

        CGFloat width =
        view.bounds.size.width;

        CGFloat height =
        view.bounds.size.height;

        CGFloat area =
        width * height;

        CGFloat screenArea =
        UIScreen.mainScreen.bounds.size.width *
        UIScreen.mainScreen.bounds.size.height;

        /*
         * Не трогаем огромные контейнеры.
         * Это важно, чтобы снова не исчезали комментарии
         * и другие элементы интерфейса.
         */

        if (screenArea > 0.0 &&
            area >= screenArea * 0.85) {

            NSLog(
                @"[LikeeAdFilter] large container skipped: %@ %.0fx%.0f",
                NSStringFromClass(adClass),
                width,
                height
            );

        }
        else {

            if (!view.hidden) {

                view.hidden = YES;

                NSLog(
                    @"[LikeeAdFilter] hidden: %@ %.0fx%.0f",
                    NSStringFromClass(adClass),
                    width,
                    height
                );
            }

            return;
        }
    }

    NSArray *subviews =
    [view.subviews copy];

    for (UIView *subview in subviews) {

        [self scanView:subview
               adClass:adClass];
    }
}

@end
