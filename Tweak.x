 #import <UIKit/UIKit.h>

@interface LikeeTweakMenu : NSObject

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *menuHeader;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSTimer *adTimer;

+ (instancetype)sharedInstance;

- (void)installButton;
- (void)buttonTapped:(UIButton *)sender;
- (void)buttonDragged:(UIPanGestureRecognizer *)gesture;

- (void)showMenu;
- (void)hideMenu;

- (void)closeButtonTapped:(UIButton *)sender;
- (void)menuDragged:(UIPanGestureRecognizer *)gesture;

- (void)switchChanged:(UISwitch *)sender;

- (void)addSwitchItem:(NSString *)title
                 icon:(NSString *)icon
                  key:(NSString *)key
                    y:(CGFloat)y
                 menu:(UIView *)menu;

- (void)scanForAds;
- (void)scanView:(UIView *)view;

- (void)startAggressiveTimer;
- (void)stopAggressiveTimer;

@end


@implementation LikeeTweakMenu

+ (instancetype)sharedInstance
{
    static LikeeTweakMenu *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[LikeeTweakMenu alloc] init];
    });

    return instance;
}


#pragma mark - Colors

- (UIColor *)purpleColor
{
    return [UIColor colorWithRed:0.48
                           green:0.18
                            blue:0.78
                           alpha:1.0];
}

- (UIColor *)lightPurpleColor
{
    return [UIColor colorWithRed:0.65
                           green:0.35
                            blue:0.95
                           alpha:1.0];
}

- (UIColor *)darkPurpleColor
{
    return [UIColor colorWithRed:0.055
                           green:0.025
                            blue:0.09
                           alpha:0.97];
}

- (UIColor *)itemColor
{
    return [UIColor colorWithRed:0.18
                           green:0.08
                            blue:0.25
                           alpha:0.88];
}


#pragma mark - Install Button

- (void)installButton
{
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

        self.window = window;

        UIButton *button =
            [UIButton buttonWithType:UIButtonTypeSystem];

        button.frame =
            CGRectMake(
                window.bounds.size.width - 68.0,
                window.bounds.size.height / 2.0 - 25.0,
                50.0,
                50.0
            );

        [button setTitle:@"LT"
                forState:UIControlStateNormal];

        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];

        button.titleLabel.font =
            [UIFont boldSystemFontOfSize:16.0];

        button.backgroundColor =
            [[self purpleColor]
                colorWithAlphaComponent:0.88];

        button.layer.cornerRadius = 25.0;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1.0;

        button.layer.borderColor =
            [[self lightPurpleColor]
                colorWithAlphaComponent:0.55].CGColor;

        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan =
            [[UIPanGestureRecognizer alloc]
                initWithTarget:self
                        action:@selector(buttonDragged:)];

        [button addGestureRecognizer:pan];

        [window addSubview:button];

        self.button = button;

        NSLog(@"[LikeeTweak] Button installed");
    });
}


#pragma mark - Button Drag

- (void)buttonDragged:(UIPanGestureRecognizer *)gesture
{
    UIView *button = gesture.view;

    CGPoint translation =
        [gesture translationInView:button.superview];

    button.center =
        CGPointMake(
            button.center.x + translation.x,
            button.center.y + translation.y
        );

    [gesture setTranslation:CGPointZero
                    inView:button.superview];
}


#pragma mark - Button Tap

- (void)buttonTapped:(UIButton *)sender
{
    if (self.menuView != nil) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}


#pragma mark - Menu

- (void)showMenu
{
    if (self.menuView != nil ||
        self.window == nil) {
        return;
    }

    CGFloat width = 275.0;
    CGFloat height = 390.0;

    CGFloat x =
        self.window.bounds.size.width
        - width
        - 15.0;

    CGFloat y =
        self.button.frame.origin.y
        - 130.0;

    if (y < 35.0) {
        y = 35.0;
    }

    if (y + height >
        self.window.bounds.size.height - 20.0) {

        y =
            self.window.bounds.size.height
            - height
            - 20.0;
    }

    UIView *overlay =
        [[UIView alloc]
            initWithFrame:self.window.bounds];

    overlay.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *overlayTap =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(hideMenu)];

    [overlay addGestureRecognizer:overlayTap];

    [self.window addSubview:overlay];

    self.overlay = overlay;

    UIView *menu =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(x, y, width, height)];

    menu.backgroundColor =
        [self darkPurpleColor];

    menu.layer.cornerRadius = 24.0;
    menu.layer.masksToBounds = YES;
    menu.layer.borderWidth = 1.0;

    menu.layer.borderColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.75].CGColor;

    [self.window addSubview:menu];

    self.menuView = menu;

    UIView *header =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(0.0, 0.0, width, 82.0)];

    header.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.18];

    [menu addSubview:header];

    self.menuHeader = header;

    UIPanGestureRecognizer *menuPan =
        [[UIPanGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(menuDragged:)];

    [header addGestureRecognizer:menuPan];

    UILabel *title =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(20.0, 12.0, width - 80.0, 32.0)];

    title.text = @"LikeeTweak";
    title.textColor = [UIColor whiteColor];
    title.font =
        [UIFont boldSystemFontOfSize:21.0];

    [header addSubview:title];

    UILabel *subtitle =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(20.0, 43.0, width - 80.0, 22.0)];

    subtitle.text = @"Экспериментальный режим";

    subtitle.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.55];

    subtitle.font =
        [UIFont systemFontOfSize:12.0];

    [header addSubview:subtitle];

    UIButton *closeButton =
        [UIButton buttonWithType:UIButtonTypeSystem];

    closeButton.frame =
        CGRectMake(width - 52.0, 18.0, 36.0, 36.0);

    [closeButton setTitle:@"×"
                 forState:UIControlStateNormal];

    [closeButton setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateNormal];

    closeButton.titleLabel.font =
        [UIFont systemFontOfSize:28.0
                          weight:UIFontWeightLight];

    closeButton.backgroundColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.08];

    closeButton.layer.cornerRadius = 18.0;

    [closeButton addTarget:self
                    action:@selector(closeButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];

    [header addSubview:closeButton];

    UIView *line =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(20.0, 81.0, width - 40.0, 1.0)];

    line.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.45];

    [menu addSubview:line];

    UIScrollView *scroll =
        [[UIScrollView alloc]
            initWithFrame:
                CGRectMake(0.0, 82.0, width, height - 82.0)];

    scroll.backgroundColor = [UIColor clearColor];
    scroll.showsVerticalScrollIndicator = YES;

    [menu addSubview:scroll];

    self.scrollView = scroll;

    UILabel *section =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(20.0, 12.0, width - 40.0, 22.0)];

    section.text = @"ЭКСПЕРИМЕНТ";

    section.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];

    section.font =
        [UIFont boldSystemFontOfSize:11.0];

    [scroll addSubview:section];

    [self addSwitchItem:
        @"Агрессивный фильтр"
        icon:@"✦"
        key:@"LikeeTweakAggressive"
        y:38.0
        menu:scroll];

    UILabel *warning =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(20.0, 92.0, width - 40.0, 70.0)];

    warning.text =
        @"Тест скрывает рекламные элементы.\nBGServerMediaView скрывается целиком.";

    warning.numberOfLines = 2;

    warning.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.45];

    warning.font =
        [UIFont systemFontOfSize:11.0];

    [scroll addSubview:warning];

    UILabel *section2 =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(20.0, 180.0, width - 40.0, 22.0)];

    section2.text = @"ИНТЕРФЕЙС";

    section2.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];

    section2.font =
        [UIFont boldSystemFontOfSize:11.0];

    [scroll addSubview:section2];

    [self addSwitchItem:
        @"Компактный интерфейс"
        icon:@"◆"
        key:@"LikeeTweakCompact"
        y:206.0
        menu:scroll];

    [self addSwitchItem:
        @"Скрыть лишние элементы"
        icon:@"◈"
        key:@"LikeeTweakHideUI"
        y:254.0
        menu:scroll];

    scroll.contentSize =
        CGSizeMake(width, 330.0);

    menu.alpha = 0.0;

    menu.transform =
        CGAffineTransformMakeScale(0.92, 0.92);

    [UIView animateWithDuration:0.18
                     animations:^{

        menu.alpha = 1.0;
        menu.transform =
            CGAffineTransformIdentity;
    }];
}


#pragma mark - Switch

- (void)addSwitchItem:(NSString *)title
                 icon:(NSString *)icon
                  key:(NSString *)key
                    y:(CGFloat)y
                 menu:(UIView *)menu
{
    UIView *container =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(
                    15.0,
                    y,
                    menu.bounds.size.width - 30.0,
                    40.0
                )];

    container.backgroundColor =
        [self itemColor];

    container.layer.cornerRadius = 11.0;

    [menu addSubview:container];

    UILabel *iconLabel =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(12.0, 5.0, 25.0, 30.0)];

    iconLabel.text = icon;
    iconLabel.textColor = [self lightPurpleColor];
    iconLabel.font =
        [UIFont systemFontOfSize:16.0];

    [container addSubview:iconLabel];

    UILabel *label =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(42.0, 0.0, 150.0, 40.0)];

    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font =
        [UIFont systemFontOfSize:13.0];

    [container addSubview:label];

    UISwitch *toggle =
        [[UISwitch alloc]
            initWithFrame:
                CGRectMake(
                    container.bounds.size.width - 59.0,
                    5.0,
                    48.0,
                    30.0
                )];

    BOOL enabled =
        [[NSUserDefaults standardUserDefaults]
            boolForKey:key];

    toggle.on = enabled;
    toggle.onTintColor = [self purpleColor];

    toggle.transform =
        CGAffineTransformMakeScale(0.78, 0.78);

    toggle.accessibilityIdentifier = key;

    [toggle addTarget:self
               action:@selector(switchChanged:)
     forControlEvents:UIControlEventValueChanged];

    [container addSubview:toggle];
}


- (void)switchChanged:(UISwitch *)sender
{
    NSString *key =
        sender.accessibilityIdentifier;

    BOOL enabled = sender.isOn;

    [[NSUserDefaults standardUserDefaults]
        setBool:enabled
        forKey:key];

    if ([key isEqualToString:@"LikeeTweakAggressive"]) {

        NSLog(
            @"[LikeeTweak] Aggressive filter: %@",
            enabled ? @"ON" : @"OFF"
        );

        if (enabled) {
            [self startAggressiveTimer];
            [self scanForAds];
        } else {
            [self stopAggressiveTimer];
        }
    }
}


#pragma mark - Advertisement Scan

- (void)scanForAds
{
    if (![[NSUserDefaults standardUserDefaults]
            boolForKey:@"LikeeTweakAggressive"]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        for (UIWindow *window in
             UIApplication.sharedApplication.windows) {

            [self scanView:window];
        }
    });
}


- (void)scanView:(UIView *)view
{
    NSString *className = NSStringFromClass([view class]);

    if ([className isEqualToString:@"BGAdComponentView"] ||
        [className isEqualToString:@"BGAdMediaView"] ||
        [className isEqualToString:@"BGServerMediaView"]) {

        NSLog(@"[LikeeTweak] HIDING AD CONTAINER: %@", className);

        view.hidden = YES;
        return;
    }

    if ([className isEqualToString:@"BGServerAdVideoPlayView"] ||
        [className isEqualToString:@"BGServerAdVideoPlayerContainer"] ||
        [className isEqualToString:@"BGServerAdImageView"] ||
        [className isEqualToString:@"LIKE.BVVideoDetailAdStyle1CardView"] ||
        [className isEqualToString:@"BVVideoDetailBigoAdStyle1AdInfoView"] ||
        [className isEqualToString:@"LIKE.BVVideoDetailAdStyle1SmallCardView"]) {

        NSLog(@"[LikeeTweak] HIDING AD VIEW: %@", className);

        view.hidden = YES;
        return;
    }

    if ([className rangeOfString:@"Moloco"
                         options:NSCaseInsensitiveSearch].location != NSNotFound) {

        NSLog(@"[LikeeTweak] HIDING MOLOCO VIEW: %@", className);

        view.hidden = YES;
        return;
    }

    if ([className isEqualToString:@"BVVideoDetailBigoAdStyle1ContainerView"]) {

    NSString *superClass =
        view.superview
        ? NSStringFromClass([view.superview class])
        : @"nil";

    NSString *info =
        [NSString stringWithFormat:
            @"BIGO AD\n"
             "FRAME: %@\n"
             "SUPER: %@\n"
             "SUPER FRAME: %@",
            NSStringFromCGRect(view.frame),
            superClass,
            view.superview
                ? NSStringFromCGRect(view.superview.frame)
                : @"nil"];

    dispatch_async(dispatch_get_main_queue(), ^{

        UIWindow *window = self.window;

        if (window != nil) {

            UILabel *debug =
                (UILabel *)[window viewWithTag:987654];

            if (debug == nil) {

                debug =
                    [[UILabel alloc]
                        initWithFrame:
                            CGRectMake(
                                10.0,
                                60.0,
                                408.0,
                                110.0
                            )];

                debug.tag = 987654;
                debug.numberOfLines = 0;

                debug.textColor = [UIColor whiteColor];

                debug.backgroundColor =
                    [[UIColor blackColor]
                        colorWithAlphaComponent:0.85];

                debug.font =
                    [UIFont systemFontOfSize:11.0];

                debug.layer.cornerRadius = 10.0;
                debug.layer.masksToBounds = YES;

                [window addSubview:debug];
            }

            debug.text = info;
        }
    });

    NSLog(@"[LikeeTweak] %@", info);

    view.hidden = YES;
    return;
}

if ([className isEqualToString:@"BGNativeAdView"]) {
    NSLog(@"[LikeeTweak] HIDING BGNativeAdView");
    view.hidden = YES;
    return;
}

if ([className isEqualToString:@"BVVideoDetailAdViewController"]) {
    NSLog(@"[LikeeTweak] FOUND AD VIEW CONTROLLER");

    view.hidden = YES;
    view.alpha = 0.0;

    return;
}

    NSArray *subviews = [view.subviews copy];

    for (UIView *subview in subviews) {
        [self scanView:subview];
    }
}


#pragma mark - Timer

- (void)startAggressiveTimer
{
    [self stopAggressiveTimer];

    self.adTimer =
        [NSTimer scheduledTimerWithTimeInterval:0.35
                                         target:self
                                       selector:@selector(scanForAds)
                                       userInfo:nil
                                        repeats:YES];

    NSLog(@"[LikeeTweak] Advertisement scanner started");
}


- (void)stopAggressiveTimer
{
    if (self.adTimer != nil) {

        [self.adTimer invalidate];

        self.adTimer = nil;

        NSLog(@"[LikeeTweak] Advertisement scanner stopped");
    }
}


#pragma mark - Menu Drag

- (void)menuDragged:(UIPanGestureRecognizer *)gesture
{
    if (self.menuView == nil ||
        self.window == nil) {
        return;
    }

    CGPoint translation =
        [gesture translationInView:self.window];

    CGPoint center =
        self.menuView.center;

    center.x += translation.x;
    center.y += translation.y;

    CGFloat halfWidth =
        self.menuView.bounds.size.width / 2.0;

    CGFloat halfHeight =
        self.menuView.bounds.size.height / 2.0;

    center.x =
        MAX(halfWidth + 5.0,
            MIN(center.x,
                self.window.bounds.size.width
                - halfWidth - 5.0));

    center.y =
        MAX(halfHeight + 5.0,
            MIN(center.y,
                self.window.bounds.size.height
                - halfHeight - 5.0));

    self.menuView.center = center;

    [gesture setTranslation:CGPointZero
                    inView:self.window];
}


#pragma mark - Close

- (void)closeButtonTapped:(UIButton *)sender
{
    [self hideMenu];
}


- (void)hideMenu
{
    UIView *menu = self.menuView;

    if (menu == nil) {
        return;
    }

    [UIView animateWithDuration:0.15
                     animations:^{

        menu.alpha = 0.0;

        menu.transform =
            CGAffineTransformMakeScale(0.92, 0.92);

    }
    completion:^(BOOL finished) {

        [menu removeFromSuperview];
        [self.overlay removeFromSuperview];

        self.menuView = nil;
        self.menuHeader = nil;
        self.overlay = nil;
        self.scrollView = nil;
    }];
}

@end


#pragma mark - Constructor

%hook BVVideoDetailAdViewController

- (void)removeAdView
{
    NSLog(@"[LikeeTweak] removeAdView CALLED");

    %orig;

    NSLog(@"[LikeeTweak] removeAdView FINISHED");
}

%end

%hook BVVideoDetailBigoAdStyle1ContainerView

- (void)didMoveToSuperview
{
    %orig;

    UIView *adView = (UIView *)self;

    NSLog(@"[LikeeTweak] BIGO CONTAINER ATTACHED");
    NSLog(@"[LikeeTweak] CLASS: %@", NSStringFromClass([adView class]));
    NSLog(@"[LikeeTweak] FRAME: %@", NSStringFromCGRect(adView.frame));

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *target = (UIView *)self;

        target.hidden = YES;
        target.alpha = 0.0;

        NSLog(@"[LikeeTweak] BIGO CONTAINER HIDDEN");
    });
}

%end

%ctor
{
    NSLog(@"[LikeeTweak] CONSTRUCTOR");

    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            3 * NSEC_PER_SEC
        ),
        dispatch_get_main_queue(),
        ^{

            LikeeTweakMenu *menu =
                [LikeeTweakMenu sharedInstance];

            [menu installButton];

            if ([[NSUserDefaults standardUserDefaults]
                    boolForKey:@"LikeeTweakAggressive"]) {

                [menu startAggressiveTimer];

                [menu scanForAds];
            }
        }
    );
}
