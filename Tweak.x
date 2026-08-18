#import <UIKit/UIKit.h>

@interface LikeeTweakMenu : NSObject

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIWindow *window;

+ (instancetype)sharedInstance;

- (void)installButton;
- (void)buttonTapped:(UIButton *)sender;
- (void)buttonDragged:(UIPanGestureRecognizer *)gesture;
- (void)showMenu;
- (void)hideMenu;

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


- (UIColor *)purpleColor
{
    return [UIColor colorWithRed:0.38
                           green:0.12
                            blue:0.65
                           alpha:1.0];
}


- (UIColor *)darkPurpleColor
{
    return [UIColor colorWithRed:0.08
                           green:0.04
                            blue:0.12
                           alpha:0.96];
}


- (void)installButton
{
    dispatch_async(dispatch_get_main_queue(), ^{

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

        self.window = window;


        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

        button.frame = CGRectMake(
            window.bounds.size.width - 70.0,
            window.bounds.size.height / 2.0 - 25.0,
            50.0,
            50.0
        );

        [button setTitle:@"LT" forState:UIControlStateNormal];

        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];

        button.backgroundColor =
            [[self purpleColor] colorWithAlphaComponent:0.82];

        button.layer.cornerRadius = 25.0;
        button.layer.masksToBounds = YES;

        button.layer.borderWidth = 1.0;

        button.layer.borderColor =
            [[UIColor whiteColor]
                colorWithAlphaComponent:0.25].CGColor;


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


- (void)buttonDragged:(UIPanGestureRecognizer *)gesture
{
    UIView *button = gesture.view;

    CGPoint translation =
        [gesture translationInView:button.superview];

    button.center = CGPointMake(
        button.center.x + translation.x,
        button.center.y + translation.y
    );

    [gesture setTranslation:CGPointZero
                    inView:button.superview];
}


- (void)buttonTapped:(UIButton *)sender
{
    if (self.menuView != nil) {
        [self hideMenu];
    }
    else {
        [self showMenu];
    }
}


- (void)showMenu
{
    if (self.menuView != nil || self.window == nil) {
        return;
    }

    CGFloat width = 250.0;
    CGFloat height = 300.0;

    CGFloat x =
        self.window.bounds.size.width - width - 15.0;

    CGFloat y =
        self.button.frame.origin.y - 110.0;

    if (y < 40.0) {
        y = 40.0;
    }

    if (y + height >
        self.window.bounds.size.height - 20.0) {

        y =
            self.window.bounds.size.height
            - height
            - 20.0;
    }


    UIView *menu =
        [[UIView alloc]
            initWithFrame:CGRectMake(
                x,
                y,
                width,
                height
            )];


    menu.backgroundColor = [self darkPurpleColor];

    menu.layer.cornerRadius = 22.0;
    menu.layer.masksToBounds = YES;

    menu.layer.borderWidth = 1.0;

    menu.layer.borderColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.65].CGColor;


    UILabel *title =
        [[UILabel alloc]
            initWithFrame:CGRectMake(
                20.0,
                15.0,
                width - 40.0,
                35.0
            )];

    title.text = @"LikeeTweak";

    title.textColor = [UIColor whiteColor];

    title.font =
        [UIFont boldSystemFontOfSize:20.0];

    [menu addSubview:title];


    UILabel *subtitle =
        [[UILabel alloc]
            initWithFrame:CGRectMake(
                20.0,
                48.0,
                width - 40.0,
                25.0
            )];

    subtitle.text = @"Настройки твика";

    subtitle.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.55];

    subtitle.font =
        [UIFont systemFontOfSize:12.0];

    [menu addSubview:subtitle];


    UIView *separator =
        [[UIView alloc]
            initWithFrame:CGRectMake(
                20.0,
                80.0,
                width - 40.0,
                1.0
            )];

    separator.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.45];

    [menu addSubview:separator];

    [self addMenuItem:@"🎥  Эфир"
                    y:95.0
                  menu:menu];

    [self addMenuItem:@"🛡  Интерфейс"
                    y:140.0
                  menu:menu];

    [self addMenuItem:@"🚫  Рекомендации"
                    y:185.0
                  menu:menu];

    [self addMenuItem:@"⚙️  Настройки"
                    y:230.0
                  menu:menu];


    [self.window addSubview:menu];

    self.menuView = menu;


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


- (void)addMenuItem:(NSString *)text
                 y:(CGFloat)y
               menu:(UIView *)menu
{
    UIButton *item =
        [UIButton buttonWithType:UIButtonTypeSystem];

    item.frame =
        CGRectMake(
            15.0,
            y,
            menu.bounds.size.width - 30.0,
            38.0
        );

    item.contentHorizontalAlignment =
        UIControlContentHorizontalAlignmentLeft;

    [item setTitle:text
          forState:UIControlStateNormal];

    [item setTitleColor:[UIColor whiteColor]
               forState:UIControlStateNormal];

    item.titleLabel.font =
        [UIFont systemFontOfSize:15.0];

    item.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.18];

    item.layer.cornerRadius = 10.0;

    [menu addSubview:item];
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

        self.menuView = nil;
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
