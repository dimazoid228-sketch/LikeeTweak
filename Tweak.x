#import <UIKit/UIKit.h>

@interface LikeeTweakMenu : NSObject

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *menuHeader;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIWindow *window;

+ (instancetype)sharedInstance;

- (void)installButton;
- (void)buttonTapped:(UIButton *)sender;
- (void)buttonDragged:(UIPanGestureRecognizer *)gesture;

- (void)showMenu;
- (void)hideMenu;

- (void)closeButtonTapped:(UIButton *)sender;
- (void)menuDragged:(UIPanGestureRecognizer *)gesture;

- (void)addSwitchItem:(NSString *)title
                 icon:(NSString *)icon
                    y:(CGFloat)y
                  menu:(UIView *)menu;

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
            window =
                UIApplication.sharedApplication.keyWindow;
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


        [button setTitleColor:
                    [UIColor whiteColor]
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


        NSLog(@"[LikeeTweak] Purple button installed");
    });
}


#pragma mark - Drag Button


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


    [gesture setTranslation:
                 CGPointZero
                   inView:button.superview];
}


#pragma mark - Button Tap


- (void)buttonTapped:(UIButton *)sender
{
    if (self.menuView != nil) {

        [self hideMenu];
    }
    else {

        [self showMenu];
    }
}


#pragma mark - Show Menu


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


    overlay.backgroundColor =
        [UIColor clearColor];


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
                CGRectMake(
                    x,
                    y,
                    width,
                    height
                )];


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
                CGRectMake(
                    0.0,
                    0.0,
                    width,
                    82.0
                )];


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
                CGRectMake(
                    20.0,
                    12.0,
                    width - 80.0,
                    32.0
                )];


    title.text = @"LikeeTweak";


    title.textColor =
        [UIColor whiteColor];


    title.font =
        [UIFont boldSystemFontOfSize:21.0];


    [header addSubview:title];


    UILabel *subtitle =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20.0,
                    43.0,
                    width - 80.0,
                    22.0
                )];


    subtitle.text =
        @"Настройки и функции";


    subtitle.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.55];


    subtitle.font =
        [UIFont systemFontOfSize:12.0];


    [header addSubview:subtitle];


    UIButton *closeButton =
        [UIButton buttonWithType:UIButtonTypeSystem];


    closeButton.frame =
        CGRectMake(
            width - 52.0,
            18.0,
            36.0,
            36.0
        );


    [closeButton setTitle:@"×"
                 forState:UIControlStateNormal];


    [closeButton setTitleColor:
                    [UIColor whiteColor]
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
                CGRectMake(
                    20.0,
                    81.0,
                    width - 40.0,
                    1.0
                )];


    line.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.45];


    [menu addSubview:line];


    UILabel *section1 =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20.0,
                    94.0,
                    width - 40.0,
                    22.0
                )];


    section1.text =
        @"ЭФИР";


    section1.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];


    section1.font =
        [UIFont boldSystemFontOfSize:11.0];


    [menu addSubview:section1];


    [self addSwitchItem:
            @"Информация об эфире"
                       icon:@"●"
                          y:120.0
                        menu:menu];


    [self addSwitchItem:
            @"Показывать модераторов"
                       icon:@"★"
                          y:168.0
                        menu:menu];


    UILabel *section2 =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20.0,
                    220.0,
                    width - 40.0,
                    22.0
                )];


    section2.text =
        @"ИНТЕРФЕЙС";


    section2.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];


    section2.font =
        [UIFont boldSystemFontOfSize:11.0];


    [menu addSubview:section2];


    [self addSwitchItem:
            @"Компактный интерфейс"
                       icon:@"◆"
                          y:246.0
                        menu:menu];


    [self addSwitchItem:
            @"Скрыть лишние элементы"
                       icon:@"◈"
                          y:294.0
                        menu:menu];


    UILabel *section3 =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    20.0,
                    346.0,
                    width - 40.0,
                    22.0
                )];


    section3.text =
        @"РЕКОМЕНДАЦИИ";


    section3.textColor =
        [[self lightPurpleColor]
            colorWithAlphaComponent:0.9];


    section3.font =
        [UIFont boldSystemFontOfSize:11.0];


    [menu addSubview:section3];


    [self addSwitchItem:
            @"Фильтр рекомендаций"
                       icon:@"✦"
                          y:372.0
                        menu:menu];


    menu.alpha = 0.0;


    menu.transform =
        CGAffineTransformMakeScale(
            0.92,
            0.92
        );


    [UIView animateWithDuration:0.18
                     animations:^{

        menu.alpha = 1.0;

        menu.transform =
            CGAffineTransformIdentity;
    }];
}


#pragma mark - Switch Item


- (void)addSwitchItem:(NSString *)title
                 icon:(NSString *)icon
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
                CGRectMake(
                    12.0,
                    5.0,
                    25.0,
                    30.0
                )];


    iconLabel.text = icon;


    iconLabel.textColor =
        [self lightPurpleColor];


    iconLabel.font =
        [UIFont systemFontOfSize:16.0];


    [container addSubview:iconLabel];


    UILabel *label =
        [[UILabel alloc]
            initWithFrame:
                CGRectMake(
                    42.0,
                    0.0,
                    container.bounds.size.width - 105.0,
                    40.0
                )];


    label.text = title;


    label.textColor =
        [UIColor whiteColor];


    label.font =
        [UIFont systemFontOfSize:13.0];


    [container addSubview:label];


    UISwitch *toggle =
        [[UISwitch alloc]
            initWithFrame:
                CGRectMake(
                    container.bounds.size.width - 58.0,
                    5.0,
                    48.0,
                    30.0
                )];


    toggle.on = NO;


    toggle.onTintColor =
        [self purpleColor];


    toggle.transform =
        CGAffineTransformMakeScale(
            0.78,
            0.78
        );


    [container addSubview:toggle];
}


#pragma mark - Menu Drag


- (void)menuDragged:(UIPanGestureRecognizer *)gesture
{
    UIView *header = gesture.view;


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


    if (center.x < halfWidth + 5.0) {
        center.x = halfWidth + 5.0;
    }


    if (center.x >
        self.window.bounds.size.width
        - halfWidth
        - 5.0) {

        center.x =
            self.window.bounds.size.width
            - halfWidth
            - 5.0;
    }


    if (center.y < halfHeight + 5.0) {
        center.y = halfHeight + 5.0;
    }


    if (center.y >
        self.window.bounds.size.height
        - halfHeight
        - 5.0) {

        center.y =
            self.window.bounds.size.height
            - halfHeight
            - 5.0;
    }


    self.menuView.center = center;


    [gesture setTranslation:
                 CGPointZero
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
            CGAffineTransformMakeScale(
                0.92,
                0.92
            );

    }
                     completion:^(BOOL finished) {

        [menu removeFromSuperview];

        [self.overlay removeFromSuperview];

        self.menuView = nil;

        self.menuHeader = nil;

        self.overlay = nil;
    }];
}

@end


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

            [[LikeeTweakMenu sharedInstance]
                installButton];
        }
    );
}
