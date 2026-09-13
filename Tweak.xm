#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark - Preferences

static NSString * const SC_PREFS_DOMAIN =
    @"com.trantu2641.systemcorner";

static NSString * const SC_CORNER_RADIUS_KEY =
    @"CornerRadius";

static CGFloat const SC_DEFAULT_CORNER_RADIUS =
    1.0;

#pragma mark - Enabled

static BOOL SCEnabled(void)
{
    NSString *version =
        UIDevice.currentDevice.systemVersion;

    return [version hasPrefix:@"16."];
}

#pragma mark - Read Settings

static CGFloat SCCornerRadius(void)
{
    NSUserDefaults *defaults =
        [[NSUserDefaults alloc]
            initWithSuiteName:SC_PREFS_DOMAIN];

    if (!defaults)
        return SC_DEFAULT_CORNER_RADIUS;

    id value =
        [defaults objectForKey:SC_CORNER_RADIUS_KEY];

    if (!value)
        return SC_DEFAULT_CORNER_RADIUS;

    CGFloat radius =
        [value doubleValue];

    if (radius < 0.0)
        radius = 0.0;

    if (radius > 100.0)
        radius = 100.0;

    return radius;
}

#pragma mark - Multitasking Window Detection

static BOOL SCIsMultitaskingWindow(UIWindow *window)
{
    if (!window)
        return NO;

    NSString *className =
        NSStringFromClass(window.class);

    /*
     * SpringBoard multitasking / app switcher.
     */

    if ([className containsString:@"Switcher"])
        return YES;

    if ([className containsString:@"Recents"])
        return YES;

    if ([className containsString:@"Multitasking"])
        return YES;

    if ([className containsString:@"FluidSwitcher"])
        return YES;

    return NO;
}

#pragma mark - Apply Corner

static void SCApplyCornerToWindow(UIWindow *window)
{
    if (!SCEnabled())
        return;

    if (!window)
        return;

    if (window.hidden)
        return;

    if (window.alpha <= 0.0)
        return;

    /*
     * Chỉ xử lý UI đa nhiệm.
     */
    if (!SCIsMultitaskingWindow(window))
        return;

    CGFloat radius =
        SCCornerRadius();

    /*
     * Không thay đổi:
     *
     * frame
     * bounds
     * center
     * transform
     *
     * Chỉ thay đổi corner.
     */
    window.layer.cornerRadius =
        radius;

    window.layer.masksToBounds =
        (radius > 0.0);

    if (@available(iOS 13.0, *))
    {
        window.layer.cornerCurve =
            kCACornerCurveContinuous;
    }
}

#pragma mark - Apply Scene

static void SCApplyScene(UIWindowScene *scene)
{
    if (!SCEnabled())
        return;

    if (!scene)
        return;

    if (scene.activationState ==
        UISceneActivationStateUnattached)
        return;

    NSArray<UIWindow *> *windows =
        scene.windows;

    for (UIWindow *window in windows)
    {
        SCApplyCornerToWindow(window);
    }
}

#pragma mark - Apply All Scenes

static void SCApplyAllScenes(void)
{
    if (!SCEnabled())
        return;

    UIApplication *application =
        UIApplication.sharedApplication;

    NSSet<UIScene *> *scenes =
        application.connectedScenes;

    for (UIScene *scene in scenes)
    {
        if (![scene
              isKindOfClass:[UIWindowScene class]])
        {
            continue;
        }

        SCApplyScene(
            (UIWindowScene *)scene
        );
    }
}

#pragma mark - Delayed Apply

static void SCScheduleApply(void)
{
    if (!SCEnabled())
        return;

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            SCApplyAllScenes();

            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    (int64_t)(
                        0.5 *
                        NSEC_PER_SEC
                    )
                ),
                dispatch_get_main_queue(),
                ^{
                    SCApplyAllScenes();
                }
            );
        }
    );
}

#pragma mark - UIWindow

%hook UIWindow

- (void)makeKeyAndVisible
{
    %orig;

    if (!SCEnabled())
        return;

    UIWindow *window = self;

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            SCApplyCornerToWindow(window);
        }
    );
}

- (void)setHidden:(BOOL)hidden
{
    %orig(hidden);

    if (!SCEnabled())
        return;

    if (hidden)
        return;

    UIWindow *window = self;

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            SCApplyCornerToWindow(window);
        }
    );
}

%end

#pragma mark - Constructor

%ctor
{
    @autoreleasepool
    {
        if (!SCEnabled())
            return;

        SCScheduleApply();
    }
}
