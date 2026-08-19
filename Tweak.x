#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#pragma mark - Ad Filter

@interface LikeeAdFilter : NSObject

@property(nonatomic, strong) NSTimer *timer;

* (instancetype)sharedInstance;

* (void)start;
* (void)stop;
* (void)scan;

@end

@implementation LikeeAdFilter

* (instancetype)sharedInstance
    {
    static LikeeAdFilter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    instance = [[LikeeAdFilter alloc] init];
    });
    return instance;
    }

* (void)start
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

    });
    NSLog(@”[LikeeTweak] Ad filter started”);
    }
* (void)stop
    {
    [self.timer invalidate];
    self.timer = nil;
    }
* (void)scanView:(UIView *)view
    {
    if (!view)
    return;
    Class cardClass =
    NSClassFromString(@“BVVideoDetailAdCardView”);
    Class styleClass =
    NSClassFromString(@“LIKE.BVVideoDetailAdStyle1CardView”);
    if (cardClass &&
    [view isKindOfClass:cardClass]) {

  if (!view.hidden) {
      view.hidden = YES;
      NSLog(@"[LikeeTweak] Hidden BVVideoDetailAdCardView");
  }
  return;

    }
    if (styleClass &&
    [view isKindOfClass:styleClass]) {

  if (!view.hidden) {
      view.hidden = YES;
      NSLog(@"[LikeeTweak] Hidden BVVideoDetailAdStyle1CardView");
  }
  return;

    }
    NSArray *children = [view.subviews copy];
    for (UIView *child in children) {
    [self scanView:child];
    }
    }
* (void)scan
    {
    if (![[NSUserDefaults standardUserDefaults]
    boolForKey:@“LikeeTweakAdFilter”]) {
    return;
    }
    if (![NSThread isMainThread]) {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self scan];
    });

  return;

    }
    for (UIWindow *window
    in UIApplication.sharedApplication.windows) {

  [self scanView:window];

    }
    }

@end

#pragma mark - Menu

@interface LikeeTweakMenu : NSObject

@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) UIView *menuView;
@property(nonatomic, strong) UIView *overlay;
@property(nonatomic, strong) UIWindow *window;

* (instancetype)sharedInstance;

@end

@implementation LikeeTweakMenu

* (instancetype)sharedInstance
    {
    static LikeeTweakMenu *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    instance = [[LikeeTweakMenu alloc] init];
    });
    return instance;
    }

* (UIColor *)purple
    {
    return [UIColor colorWithRed:0.48
    green:0.18
    blue:0.78
    alpha:1.0];
    }
* (void)findWindow
    {
    if (self.window)
    return;
    if (@available(iOS 13.0, *)) {

  for (UIScene *scene
       in UIApplication.sharedApplication.connectedScenes) {
      if (scene.activationState !=
          UISceneActivationStateForegroundActive)
          continue;
      if (![scene isKindOfClass:[UIWindowScene class]])
          continue;
      for (UIWindow *window
           in ((UIWindowScene *)scene).windows) {
          if (window.isKeyWindow) {
              self.window = window;
              return;
          }
      }
  }

    }
    self.window =
    UIApplication.sharedApplication.keyWindow;
    }
* (void)install
    {
    dispatch_async(dispatch_get_main_queue(), ^{

  [self findWindow];
  if (!self.window || self.button)
      return;
  UIButton *button =
      [UIButton buttonWithType:UIButtonTypeSystem];
  button.frame =
      CGRectMake(
          self.window.bounds.size.width - 68.0,
          self.window.bounds.size.height / 2.0 - 25.0,
          50.0,
          50.0
      );
  [button setTitle:@"LT"
          forState:UIControlStateNormal];
  [button setTitleColor:UIColor.whiteColor
               forState:UIControlStateNormal];
  button.titleLabel.font =
      [UIFont boldSystemFontOfSize:16.0];
  button.backgroundColor =
      [[self purple] colorWithAlphaComponent:0.9];
  button.layer.cornerRadius = 25.0;
  button.layer.masksToBounds = YES;
  [button addTarget:self
             action:@selector(toggle)
   forControlEvents:UIControlEventTouchUpInside];
  [self.window addSubview:button];
  self.button = button;
  NSLog(@"[LikeeTweak] Menu installed");

    });
    }
* (void)toggle
    {
    if (self.menuView)
    [self hide];
    else
    [self show];
    }
* (void)show
    {
    if (!self.window)
    return;
    CGFloat width = 275.0;
    CGFloat height = 190.0;
    CGFloat x =
    self.window.bounds.size.width
    - width
    - 15.0;
    CGFloat y =
    self.button.frame.origin.y - 80.0;
    if (y < 30.0)
    y = 30.0;
    UIView *overlay =
    [[UIView alloc]
    initWithFrame:self.window.bounds];
    overlay.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc]
    initWithTarget:self
    action:@selector(hide)];
    [overlay addGestureRecognizer:tap];
    [self.window addSubview:overlay];
    self.overlay = overlay;
    UIView *menu =
    [[UIView alloc]
    initWithFrame:CGRectMake(x, y, width, height)];
    menu.backgroundColor =
    [UIColor colorWithRed:0.055
    green:0.025
    blue:0.09
    alpha:0.98];
    menu.layer.cornerRadius = 22.0;
    menu.layer.borderWidth = 1.0;
    menu.layer.borderColor =
    [[self purple]
    colorWithAlphaComponent:0.8].CGColor;
    [self.window addSubview:menu];
    self.menuView = menu;
    UILabel *title =
    [[UILabel alloc]
    initWithFrame:CGRectMake(18, 12, 180, 30)];
    title.text = @“LikeeTweak”;
    title.textColor = UIColor.whiteColor;
    title.font =
    [UIFont boldSystemFontOfSize:21];
    [menu addSubview:title];
    UIButton *close =
    [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame =
    CGRectMake(width - 52, 12, 36, 36);
    [close setTitle:@“×”
    forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor
    forState:UIControlStateNormal];
    close.titleLabel.font =
    [UIFont systemFontOfSize:28];
    [close addTarget:self
    action:@selector(hide)
    forControlEvents:UIControlEventTouchUpInside];
    [menu addSubview:close];
    UILabel *label =
    [[UILabel alloc]
    initWithFrame:CGRectMake(20, 58, 170, 45)];
    label.text = @“Фильтр рекламы”;
    label.textColor = UIColor.whiteColor;
    label.font =
    [UIFont systemFontOfSize:15];
    [menu addSubview:label];
    UISwitch *toggle =
    [[UISwitch alloc]
    initWithFrame:CGRectMake(width - 70, 60, 50, 30)];
    toggle.on =
    [[NSUserDefaults standardUserDefaults]
    boolForKey:@“LikeeTweakAdFilter”];
    toggle.onTintColor = [self purple];
    [toggle addTarget:self
    action:@selector(adSwitch:)
    forControlEvents:UIControlEventValueChanged];
    [menu addSubview:toggle];
    UILabel *info =
    [[UILabel alloc]
    initWithFrame:CGRectMake(20, 112, width - 40, 55)];
    info.text =
    @“Скрывает найденные рекламные\nкарточки, не трогая BGServerAdImageView.”;
    info.numberOfLines = 2;
    info.textColor =
    [UIColor.whiteColor colorWithAlphaComponent:0.45];
    info.font =
    [UIFont systemFontOfSize:11];
    [menu addSubview:info];
    }
* (void)adSwitch:(UISwitch *)sender
    {
    BOOL enabled = sender.isOn;
    [[NSUserDefaults standardUserDefaults]
    setBool:enabled
    forKey:@“LikeeTweakAdFilter”];
    if (enabled)
    [[LikeeAdFilter sharedInstance] start];
    else
    [[LikeeAdFilter sharedInstance] stop];
    }
* (void)hide
    {
    [self.menuView removeFromSuperview];
    [self.overlay removeFromSuperview];
    self.menuView = nil;
    self.overlay = nil;
    }

@end

#pragma mark - Constructor

%ctor
{
NSLog(@”[LikeeTweak] Constructor”);

dispatch_after(
    dispatch_time(
        DISPATCH_TIME_NOW,
        3 * NSEC_PER_SEC
    ),
    dispatch_get_main_queue(),
    ^{
        LikeeTweakMenu *menu =
            [LikeeTweakMenu sharedInstance];
        [menu install];
        if ([[NSUserDefaults standardUserDefaults]
             boolForKey:@"LikeeTweakAdFilter"]) {
            [[LikeeAdFilter sharedInstance] start];
        }
    }
);

}
