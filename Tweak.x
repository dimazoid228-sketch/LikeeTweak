if (self.menuView != nil) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}


#pragma mark - Menu

- (void)showMenu {

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

        y = self.window.bounds.size.height
            - height - 20.0;
    }


    UIView *menu =
        [[UIView alloc]
            initWithFrame:CGRectMake(
                x,
                y,
                width,
                height
            )];


    menu.backgroundColor =
        [self darkPurpleColor];

    menu.layer.cornerRadius = 22.0;
    menu.layer.masksToBounds = YES;

    menu.layer.borderWidth = 1.0;
    menu.layer.borderColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.65].CGColor;


    // Title

    UILabel *title =
        [[UILabel alloc]
            initWithFrame:CGRectMake(
                20,
                15,
                width - 40,
                35
            )];

    title.text = @"LikeeTweak";
    title.textColor = UIColor.whiteColor;
    title.font =
        [UIFont boldSystemFontOfSize:20.0];

    [menu addSubview:title];


    UILabel *subtitle =
        [[UILabel alloc]
            initWithFrame:CGRectMake(
                20,
                48,
                width - 40,
                25
            )];

    subtitle.text = @"Настройки твика";
    subtitle.textColor =
        [[UIColor whiteColor]
            colorWithAlphaComponent:0.55];

    subtitle.font =
        [UIFont systemFontOfSize:12.0];

    [menu addSubview:subtitle];


    // Separator

    UIView *separator =
        [[UIView alloc]
            initWithFrame:CGRectMake(
                20,
                80,
                width - 40,
                1
            )];

    separator.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.45];

    [menu addSubview:separator];


    // Sections

    [self addMenuItem:@"🎥  Эфир"
                y:95
               menu:menu];

    [self addMenuItem:@"🛡  Интерфейс"
                y:140
               menu:menu];

    [self addMenuItem:@"🚫  Рекомендации"
                y:185
               menu:menu];

    [self addMenuItem:@"⚙️  Настройки"
                y:230
               menu:menu];


    [self.window addSubview:menu];

    self.menuView = menu;


    menu.alpha = 0.0;
    menu.transform =
        CGAffineTransformMakeScale(0.92, 0.92);

    [UIView animateWithDuration:0.18
                     animations:^{

        menu.alpha = 1.0;
        menu.transform = CGAffineTransformIdentity;

    }];
}


#pragma mark - Menu Items

- (void)addMenuItem:(NSString *)text
                 y:(CGFloat)y
                menu:(UIView *)menu {

    UIButton *item =
        [UIButton buttonWithType:UIButtonTypeSystem];

    item.frame =
        CGRectMake(
            15,
            y,
            menu.bounds.size.width - 30,
            38
        );

    item.contentHorizontalAlignment =
        UIControlContentHorizontalAlignmentLeft;

    [item setTitle:text
          forState:UIControlStateNormal];

    [item setTitleColor:UIColor.whiteColor
               forState:UIControlStateNormal];

    item.titleLabel.font =
        [UIFont systemFontOfSize:15.0
                          weight:UIFontWeightMedium];

    item.backgroundColor =
        [[self purpleColor]
            colorWithAlphaComponent:0.18];

    item.layer.cornerRadius = 10.0;

    [menu addSubview:item];
}


#pragma mark - Hide

- (void)hideMenu {

    UIView *menu = self.menuView;

    if (!menu) {
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


%ctor {

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
