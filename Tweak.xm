#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - Configuration

static NSString * const SC16_PREFS =
    @"com.trantu2641.systemcorner";

static NSString * const SC16_CORNER_KEY =
    @"CornerRadius";

static CGFloat const SC16_DEFAULT_CORNER =
    1.0;

#pragma mark - Preferences

static CGFloat SC16CornerRadius(void)
{
    NSUserDefaults *defaults =
        [[NSUserDefaults alloc] initWithSuiteName:SC16_PREFS];

    if (!defaults)
        return SC16_DEFAULT_CORNER;

    id value =
        [defaults objectForKey:SC16_CORNER_KEY];

    if (!value)
        return SC16_DEFAULT_CORNER;

    CGFloat radius =
        [value doubleValue];

    if (radius < 0.0)
        radius = 0.0;

    if (radius > 100.0)
        radius = 100.0;

    return radius;
}

#pragma mark - Enable

static BOOL SC16Enabled(void)
{
    NSString *version =
        UIDevice.currentDevice.systemVersion;

    return [version hasPrefix:@"16."];
}

#pragma mark - Window Detection

static BOOL SC16IsKeyboardWindow(UIWindow *window)
{
    if (!window)
        return NO;

    NSString *name =
        NSStringFromClass(window.class);

    if ([name containsString:@"UITextEffectsWindow"])
        return YES;

    if ([name containsString:@"UIRemoteKeyboardWindow"])
        return YES;

    if ([name containsString:@"Keyboard"])
        return YES;

    if ([name containsString:@"KeyboardWindow"])
        return YES;

    return NO;
}

static BOOL SC16IsStatusBarWindow(UIWindow *window)
{
    if (!window)
        return NO;

    NSString *name =
        NSStringFromClass(window.class);

    if ([name containsString:@"StatusBar"])
        return YES;

    if ([name containsString:@"_UIStatusBar"])
        return YES;

    return NO;
}

#pragma mark - Multitasking Detection

/*
 * Chỉ xử lý các window thuộc giao diện đa nhiệm.
 *
 * Không tác động vào UIWindow bình thường
 * của ứng dụng.
 */
static BOOL SC16IsMultitaskingWindow(UIWindow *window)
{
    if (!window)
        return NO;

    NSString *name =
        NSStringFromClass(window.class);

    /*
     * Các private window/class thường gặp
     * trong SpringBoard / multitasking.
     */
    if ([name containsString:@"SBFluidSwitcher"])
        return YES;

    if ([name containsString:@"Switcher"])
        return YES;

    if ([name containsString:@"Recents"])
        return YES;

    if ([name containsString:@"Multitasking"])
        return YES;

    if ([name containsString:@"AppSwitcher"])
        return YES;

    if ([name containsString:@"SwitcherWindow"])
        return YES;

    return NO;
}

#pragma mark - Corner Application

static void SC16ApplyCorner(UIWindow *window)
{
    if (!SC16Enabled())
        return;

    if (!window)
        return;

    if (window.hidden)
        return;

    if (window.alpha <= 0.0)
        return;

    /*
     * Không đụng keyboard.
     */
    if (SC16IsKeyboardWindow(window))
        return;

    /*
     * Không đụng Status Bar.
     */
    if (SC16IsStatusBarWindow(window))
        return;

    /*
     * Chỉ bo giao diện đa nhiệm.
     */
    if (!SC16IsMultitaskingWindow(window))
        return;

    CGFloat radius =
        SC16CornerRadius();

    if (radius <= 0.0)
    {
        window.layer.cornerRadius = 0.0;
        window.layer.masksToBounds = NO;
        return;
    }

    /*
     * Không thay đổi frame / bounds / transform.
     *
     * Chỉ bo chính layer của UI đa nhiệm.
     */
    window.layer.cornerRadius =
        radius;

    window.layer.masksToBounds =
        YES;

    /*
     * iOS 13+.
     */
    if (@available(iOS 13.0, *))
    {
        window.layer.cornerCurve =
            kCACornerCurveContinuous;
    }
}

#pragma mark - Apply Scene

static void SC16ApplyScene(UIWindowScene *scene)
{
    if (!SC16Enabled())
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
        if (!window)
            continue;

        SC16ApplyCorner(window);
    }
}

#pragma mark - Apply All Scenes

static void SC16ApplyAllScenes(void)
{
    if (!SC16Enabled())
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

        SC16ApplyScene(
            (UIWindowScene *)scene
        );
    }
}

#pragma mark - Delayed Apply

static void SC16ScheduleApply(void)
{
    if (!SC16Enabled())
        return;

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            SC16ApplyAllScenes();

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
                    SC16ApplyAllScenes();
                }
            );
        }
    );
}

#pragma mark - UIWindow Hooks

%hook UIWindow

- (void)makeKeyAndVisible
{
    %orig;

    if (!SC16Enabled())
        return;

    UIWindow *window =
        self;

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            SC16ApplyCorner(window);
        }
    );
}

- (void)setHidden:(BOOL)hidden
{
    %orig(hidden);

    if (!SC16Enabled())
        return;

    if (hidden)
        return;

    UIWindow *window =
        self;

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            if (!window.hidden)
            {
                SC16ApplyCorner(window);
            }
        }
    );
}

%end

#pragma mark - Constructor

%ctor
{
    @autoreleasepool
    {
        if (!SC16Enabled())
            return;

        SC16ScheduleApply();
    }
}
