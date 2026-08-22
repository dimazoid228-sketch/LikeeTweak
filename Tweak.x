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

- (void)startAdObserver;
- (void)stopAdObserver;

@end


#pragma mark -
#pragma mark Advertisement helpers
#pragma mark -

static BOOL LTAdFilterEnabled(void)
{
    return [[NSUserDefaults standardUserDefaults]
                boolForKey:@"LikeeTweakAggressive"];
}


static BOOL LTIsCompleteAdCell(UIView *view)
{
    if (!view)
        return NO;

    NSString *name =
        NSStringFromClass([view class]);

    return [name isEqualToString:
                @"BVVideoNativeAdTableViewCell"];
}


static void LTRemoveCompleteAdCell(UIView *view)
{
    if (!view)
        return;

    dispatch_async(dispatch_get_main_queue(), ^{

        if (!view)
            return;

        if (!view.superview)
            return;

        /*
         * Проверяем ещё раз непосредственно
         * перед удалением.
         */

        if (!LTAdFilterEnabled())
            return;

        NSString *className =
            NSStringFromClass([view class]);

        if (![className isEqualToString:
                @"BVVideoNativeAdTableViewCell"]) {
            return;
        }

        NSLog(@"[LikeeTweak] =============================");
        NSLog(@"[LikeeTweak] COMPLETE AD CELL");
        NSLog(@"[LikeeTweak] class = %@", className);
        NSLog(@"[LikeeTweak] frame = %@",
              NSStringFromCGRect(view.frame));
        NSLog(@"[LikeeTweak] removing...");
        NSLog(@"[LikeeTweak] =============================");

        /*
         * Сначала убираем содержимое.
         */

        view.hidden = YES;
        view.alpha = 0.0;

        /*
         * Запоминаем superview.
         */

        UIView *parent =
            view.superview;

        /*
         * Убираем ячейку из иерархии.
         */

        [view removeFromSuperview];

        /*
         * Просим родителя пересчитать layout.
         */

        [parent setNeedsLayout];
        [parent layoutIfNeeded];

        /*
         * Если родитель — таблица,
         * обновляем layout.
         */

        if ([parent isKindOfClass:
                [UITableView class]]) {

            UITableView *table =
                (UITableView *)parent;

            [table beginUpdates];
            [table endUpdates];

            [table setNeedsLayout];
            [table layoutIfNeeded];
        }

        /*
         * Иногда Likee держит ячейку
         * внутри дополнительной UIView.
         * Поэтому просим layout у всей цепочки.
         */

        UIView *current =
            parent;

        for (NSInteger i = 0;
             current && i < 5;
             i++) {

            [current setNeedsLayout];
            [current layoutIfNeeded];

            current =
                current.superview;
        }

        NSLog(@"[LikeeTweak] AD CELL REMOVED");
    });
}


#pragma mark -
#pragma mark Menu
#pragma mark -

@implementation LikeeTweakMenu

+ (instancetype)sharedInstance
{
    static LikeeTweakMenu *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance =
            [[LikeeTweakMenu alloc] init];
    });

    return instance;
}


#pragma mark Colors

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


#pragma mark -
#pragma mark Install button
#pragma mark -

- (void)installButton
{
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.button)
            return;

        UIWindow *window = nil;

        if (@available(iOS 13.0, *)) {

            for (UIScene *scene in
                 UIApplication.sharedApplication.connectedScenes) {

                if (scene.activationState !=
                    UISceneActivationStateForegroundActive)
                    continue;

                if (![scene isKindOfClass:
                        [UIWindowScene class]])
                    continue;

                for (UIWindow *candidate in
                     ((UIWindowScene *)scene).windows) {

                    if (candidate.isKeyWindow) {

                        window =
                            candidate;

                        break;
                    }
                }

                if (window)
                    break;
            }
        }

        if (!window)
            window =
                UIApplication.sharedApplication.keyWindow;

        if (!window) {

            NSLog(@"[LikeeTweak] Window not found");

            return;
        }

        self.window =
            window;

        UIButton *button =
            [UIButton buttonWithType:
                UIButtonTypeSystem];

        button.frame =
            CGRectMake(
                window.bounds.size.width - 68.0,
                window.bounds.size.height / 2.0 - 25.0,
                50.0,
                50.0
            );

        [button setTitle:@"LT"
                forState:UIControlStateNormal];

        [button setTitleColor:
                    [UIColor whiteColor]
                    forState:UIControlStateNormal];

        button.titleLabel.font =
            [UIFont boldSystemFontOfSize:16.0];

        button.backgroundColor =
            [[self purpleColor]
                colorWithAlphaComponent:0.88];

        button.layer.cornerRadius =
            25.0;

        button.layer.masksToBounds =
            YES;

        button.layer.borderWidth =
            1.0;

        button.layer.borderColor =
            [[self lightPurpleColor]
                colorWithAlphaComponent:0.55].CGColor;

        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:
             UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan =
            [[UIPanGestureRecognizer alloc]
                initWithTarget:self
                        action:@selector(buttonDragged:)];

        [button addGestureRecognizer:pan];

        [window addSubview:button];

        self.button =
            button;

        NSLog(@"[LikeeTweak] Button installed");
    });
}


#pragma mark Button drag

- (void)buttonDragged:
    (UIPanGestureRecognizer *)gesture
{
    UIView *button =
        gesture.view;

    CGPoint translation =
        [gesture translationInView:
            button.superview];

    button.center =
        CGPointMake(
            button.center.x + translation.x,
            button.center.y + translation.y
        );

    [gesture setTranslation:
        CGPointZero
        inView:button.superview];
}


#pragma mark Button tap

- (void)buttonTapped:
    (UIButton *)sender
{
    if (self.menuView)
        [self hideMenu];
    else
        [self showMenu];
}


#pragma mark -
#pragma mark Menu
#pragma mark -

- (void)showMenu
{
    if (self.menuView ||
        !self.window)
        return;

    CGFloat width =
        275.0;

    CGFloat height =
        390.0;

    CGFloat x =
        self.window.bounds.size.width
        - width
        - 15.0;

    CGFloat y =
        self.button.frame.origin.y
        - 130.0;

    if (y < 35.0)
        y = 35.0;

    if (y + height >
        self.window.bounds.size.height - 20.0) {

        y =
            self.window.bounds.size.height
            - height
            - 20.0;
    }

    UIView *overlay =
        [[UIView alloc]
            initWithFrame:
                self.window.bounds];

    overlay.backgroundColor =
        [UIColor clearColor];

    UITapGestureRecognizer *overlayTap =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(hideMenu)];

    [overlay addGestureRecognizer:
        overlayTap];

    [self.window addSubview:
        overlay];

    self.overlay =
        overlay;

    UIView *menu =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(
                    x,
                    y,
                    width,
                    height
                )];

    menu.backgroundColor =
        [self darkPurpleColor];

    menu.layer.cornerRadius =
        24.0;

    menu.layer.masksToBounds =
        YES;

    menu.layer.borderWidth =
        1.0;

    menu.layer.borderColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.75].CGColor;

    [self.window addSubview:
        menu];

    self.menuView =
        menu;

    UIView *header =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(
                    0,
                    0,
                    width,
                    82
                )];

    header.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.18];

    [menu addSubview:
        header];

    self.menuHeader =
        header;

    UIPanGestureRecognizer *menuPan =
        [[UIPanGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(menuDragged:)];

    [header addGestureRecognizer:
        menuPan];

    UILabel *title =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20,
                    12,
                    width - 80,
                    32
                )];

    title.text =
        @"LikeeTweak";

    title.textColor =
        [UIColor whiteColor];

    title.font =
        [UIFont boldSystemFontOfSize:21];

    [header addSubview:
        title];

    UILabel *subtitle =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20,
                    43,
                    width - 80,
                    22
                )];

    subtitle.text =
        @"Экспериментальный режим";

    subtitle.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.55];

    subtitle.font =
        [UIFont systemFontOfSize:12];

    [header addSubview:
        subtitle];

    UIButton *closeButton =
        [UIButton buttonWithType:
            UIButtonTypeSystem];

    closeButton.frame =
        CGRectMake(
            width - 52,
            18,
            36,
            36
        );

    [closeButton setTitle:@"×"
                 forState:
                     UIControlStateNormal];

    [closeButton setTitleColor:
                    [UIColor whiteColor]
                  forState:
                    UIControlStateNormal];

    closeButton.titleLabel.font =
        [UIFont systemFontOfSize:28
                          weight:
                            UIFontWeightLight];

    closeButton.backgroundColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.08];

    closeButton.layer.cornerRadius =
        18;

    [closeButton addTarget:self
                    action:@selector(closeButtonTapped:)
          forControlEvents:
              UIControlEventTouchUpInside];

    [header addSubview:
        closeButton];

    UIView *line =
        [[UIView alloc]
            initWithFrame:
                CGRectMake(
                    20,
                    81,
                    width - 40,
                    1
                )];

    line.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.45];

    [menu addSubview:
        line];

    UIScrollView *scroll =
        [[UIScrollView alloc]
            initWithFrame:
                CGRectMake(
                    0,
                    82,
                    width,
                    height - 82
                )];

    scroll.backgroundColor =
        [UIColor clearColor];

    scroll.showsVerticalScrollIndicator =
        YES;

    [menu addSubview:
        scroll];

    self.scrollView =
        scroll;

    UILabel *section =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20,
                    12,
                    width - 40,
                    22
                )];

    section.text =
        @"РЕКЛАМА";

    section.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];

    section.font =
        [UIFont boldSystemFontOfSize:11];

    [scroll addSubview:
        section];

    [self addSwitchItem:
        @"Убирать рекламу из рекомендаций"
        icon:@"✦"
        key:@"LikeeTweakAggressive"
        y:38
        menu:scroll];

    UILabel *warning =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20,
                    92,
                    width - 40,
                    65
                )];

    warning.text =
        @"Удаляется целая рекламная ячейка,\n"
         "а не отдельные элементы рекламы.";

    warning.numberOfLines =
        2;

    warning.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.45];

    warning.font =
        [UIFont systemFontOfSize:11];

    [scroll addSubview:
        warning];

    UILabel *section2 =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20,
                    175,
                    width - 40,
                    22
                )];

    section2.text =
        @"ИНТЕРФЕЙС";

    section2.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];

    section2.font =
        [UIFont boldSystemFontOfSize:11];

    [scroll addSubview:
        section2];

    [self addSwitchItem:
        @"Компактный интерфейс"
        icon:@"◆"
        key:@"LikeeTweakCompact"
        y:201
        menu:scroll];

    [self addSwitchItem:
        @"Скрыть лишние элементы"
        icon:@"◈"
        key:@"LikeeTweakHideUI"
        y:249
        menu:scroll];

    scroll.contentSize =
        CGSizeMake(
            width,
            315
        );

    menu.alpha =
        0.0;

    menu.transform =
        CGAffineTransformMakeScale(
            0.92,
            0.92
        );

    [UIView animateWithDuration:0.18
                     animations:^{

        menu.alpha =
            1.0;

        menu.transform =
            CGAffineTransformIdentity;
    }];
}


#pragma mark Switch item

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
                    15,
                    y,
                    menu.bounds.size.width - 30,
                    40
                )];

    container.backgroundColor =
        [self itemColor];

    container.layer.cornerRadius =
        11;

    [menu addSubview:
        container];

    UILabel *iconLabel =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    12,
                    5,
                    25,
                    30
                )];

    iconLabel.text =
        icon;

    iconLabel.textColor =
        [self lightPurpleColor];

    iconLabel.font =
        [UIFont systemFontOfSize:16];

    [container addSubview:
        iconLabel];

    UILabel *label =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    42,
                    0,
                    170,
                    40
                )];

    label.text =
        title;

    label.textColor =
        [UIColor whiteColor];

    label.font =
        [UIFont systemFontOfSize:13];

    [container addSubview:
        label];

    UISwitch *toggle =
        [[UISwitch alloc]
            initWithFrame:
                CGRectMake(
                    container.bounds.size.width - 59,
                    5,
                    48,
                    30
                )];

    toggle.on =
        [[NSUserDefaults standardUserDefaults]
            boolForKey:key];

    toggle.onTintColor =
        [self purpleColor];

    toggle.transform =
        CGAffineTransformMakeScale(
            0.78,
            0.78
        );

    toggle.accessibilityIdentifier =
        key;

    [toggle addTarget:self
               action:@selector(switchChanged:)
     forControlEvents:
         UIControlEventValueChanged];

    [container addSubview:
        toggle];
}


#pragma mark Switch changed

- (void)switchChanged:
    (UISwitch *)sender
{
    NSString *key =
        sender.accessibilityIdentifier;

    BOOL enabled =
        sender.isOn;

    [[NSUserDefaults standardUserDefaults]
        setBool:enabled
        forKey:key];

    if ([key isEqualToString:
            @"LikeeTweakAggressive"]) {

        NSLog(
            @"[LikeeTweak] Ad filter: %@",
            enabled ? @"ON" : @"OFF"
        );

        if (enabled) {

            [self startAdObserver];
            [self scanForAds];

        } else {

            [self stopAdObserver];
        }
    }
}


#pragma mark -
#pragma mark Advertisement scan
#pragma mark -

- (void)scanForAds
{
    if (!LTAdFilterEnabled())
        return;

    dispatch_async(dispatch_get_main_queue(), ^{

        NSMutableArray *windows =
            [NSMutableArray array];

        if (@available(iOS 13.0, *)) {

            for (UIScene *scene in
                 UIApplication.sharedApplication.connectedScenes) {

                if (scene.activationState !=
                    UISceneActivationStateForegroundActive)
                    continue;

                if (![scene isKindOfClass:
                        [UIWindowScene class]])
                    continue;

                for (UIWindow *window in
                     ((UIWindowScene *)scene).windows) {

                    if (![windows containsObject:window])
                        [windows addObject:window];
                }
            }
        }

        if (windows.count == 0) {

            UIWindow *window =
                UIApplication.sharedApplication.keyWindow;

            if (window)
                [windows addObject:window];
        }

        for (UIWindow *window in windows) {

            [self scanView:window];
        }
    });
}


- (void)scanView:(UIView *)view
{
    if (!view)
        return;

    /*
     * ВАЖНО:
     *
     * Ищем только целую рекламную ячейку.
     *
     * Не трогаем:
     * BGNativeAdView
     * BGAdMediaView
     * BGServerMediaView
     * BGServerAdVideoPlayView
     *
     * Поэтому не должно оставаться
     * чёрного видеоблока от частично
     * удалённой рекламы.
     */

    if (LTIsCompleteAdCell(view)) {

        LTRemoveCompleteAdCell(view);

        return;
    }

    NSArray *subviews =
        [view.subviews copy];

    for (UIView *subview in subviews) {

        [self scanView:subview];
    }
}


#pragma mark -
#pragma mark Observer
#pragma mark -

- (void)startAdObserver
{
    [self stopAdObserver];

    /*
     * Первоначальная проверка.
     */

    [self performSelector:
        @selector(scanForAds)
        withObject:nil
        afterDelay:0.05];

    /*
     * Небольшой повторный поиск нужен,
     * потому что Likee может создать
     * рекламную ячейку после появления
     * самой рекомендации.
     */

    [self performSelector:
        @selector(scanForAds)
        withObject:nil
        afterDelay:0.20];

    [self performSelector:
        @selector(scanForAds)
        withObject:nil
        afterDelay:0.50];

    [self performSelector:
        @selector(scanForAds)
        withObject:nil
        afterDelay:1.0];

    NSLog(@"[LikeeTweak] Advertisement observer started");
}


- (void)stopAdObserver
{
    [NSObject
        cancelPreviousPerformRequestsWithTarget:self
                                       selector:
                                         @selector(scanForAds)
                                         object:nil];

    NSLog(@"[LikeeTweak] Advertisement observer stopped");
}


#pragma mark -
#pragma mark Menu drag
#pragma mark -

- (void)menuDragged:
    (UIPanGestureRecognizer *)gesture
{
    if (!self.menuView ||
        !self.window)
        return;

    CGPoint translation =
        [gesture translationInView:
            self.window];

    CGPoint center =
        self.menuView.center;

    center.x +=
        translation.x;

    center.y +=
        translation.y;

    CGFloat halfWidth =
        self.menuView.bounds.size.width / 2;

    CGFloat halfHeight =
        self.menuView.bounds.size.height / 2;

    center.x =
        MAX(
            halfWidth + 5,
            MIN(
                center.x,
                self.window.bounds.size.width
                - halfWidth - 5
            )
        );

    center.y =
        MAX(
            halfHeight + 5,
            MIN(
                center.y,
                self.window.bounds.size.height
                - halfHeight - 5
            )
        );

    self.menuView.center =
        center;

    [gesture setTranslation:
        CGPointZero
        inView:self.window];
}


#pragma mark Close

- (void)closeButtonTapped:
    (UIButton *)sender
{
    [self hideMenu];
}


- (void)hideMenu
{
    UIView *menu =
        self.menuView;

    if (!menu)
        return;

    [UIView animateWithDuration:0.15
                     animations:^{

        menu.alpha =
            0.0;

        menu.transform =
            CGAffineTransformMakeScale(
                0.92,
                0.92
            );

    }
    completion:^(BOOL finished) {

        [menu removeFromSuperview];

        [self.overlay removeFromSuperview];

        self.menuView =
            nil;

        self.menuHeader =
            nil;

        self.overlay =
            nil;

        self.scrollView =
            nil;
    }];
}

@end


#pragma mark -
#pragma mark Complete advertisement cell hook
#pragma mark -

%hook BVVideoNativeAdTableViewCell

- (void)didMoveToWindow
{
    %orig;

    if (!LTAdFilterEnabled())
        return;

    NSLog(@"[LikeeTweak] BVVideoNativeAdTableViewCell APPEARED");

    dispatch_async(dispatch_get_main_queue(), ^{

        if (!LTAdFilterEnabled())
            return;

        UIView *cell =
            (UIView *)self;

        LTRemoveCompleteAdCell(cell);
    });
}


- (void)didMoveToSuperview
{
    %orig;

    if (!LTAdFilterEnabled())
        return;

    NSLog(@"[LikeeTweak] BVVideoNativeAdTableViewCell ADDED");

    dispatch_async(dispatch_get_main_queue(), ^{

        if (!LTAdFilterEnabled())
            return;

        UIView *cell =
            (UIView *)self;

        LTRemoveCompleteAdCell(cell);
    });
}

%end


#pragma mark -
#pragma mark Constructor
#pragma mark -

%ctor
{
    NSLog(@"[LikeeTweak] Constructor");

    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            2 * NSEC_PER_SEC
        ),
        dispatch_get_main_queue(),
        ^{

            LikeeTweakMenu *menu =
                [LikeeTweakMenu sharedInstance];

            [menu installButton];

            if (LTAdFilterEnabled()) {

                [menu startAdObserver];

                [menu scanForAds];
            }
        }
    );
}
