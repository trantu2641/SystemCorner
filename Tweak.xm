#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

static CGFloat SHAStatusDelta = 0.0;
static CGFloat SHAHomeDelta = 0.0;

static NSMapTable *SHAOriginalTransforms;

#pragma mark - Preferences

static void SHA_LoadPreferences(void)
{
    CFStringRef domain =
        CFSTR("com.congtu.statushomebaradjuster");

    CFPreferencesAppSynchronize(domain);

    CFPropertyListRef statusValue =
        CFPreferencesCopyAppValue(
            CFSTR("StatusBarOffset"),
            domain
        );

    CFPropertyListRef homeValue =
        CFPreferencesCopyAppValue(
            CFSTR("HomeBarOffset"),
            domain
        );

    SHAStatusDelta = 0.0;
    SHAHomeDelta = 0.0;

    if (statusValue &&
        CFGetTypeID(statusValue) == CFNumberGetTypeID())
    {
        double value = 0.0;

        CFNumberGetValue(
            (CFNumberRef)statusValue,
            kCFNumberDoubleType,
            &value
        );

        SHAStatusDelta =
            (CGFloat)MAX(-120.0, MIN(120.0, value));
    }

    if (homeValue &&
        CFGetTypeID(homeValue) == CFNumberGetTypeID())
    {
        double value = 0.0;

        CFNumberGetValue(
            (CFNumberRef)homeValue,
            kCFNumberDoubleType,
            &value
        );

        SHAHomeDelta =
            (CGFloat)MAX(-120.0, MIN(120.0, value));
    }

    if (statusValue)
        CFRelease(statusValue);

    if (homeValue)
        CFRelease(homeValue);
}

#pragma mark - Portrait

static BOOL SHA_IsPortrait(void)
{
    UIApplication *app =
        [UIApplication sharedApplication];

    if (!app)
        return NO;

    if (@available(iOS 13.0, *))
    {
        for (UIScene *scene in app.connectedScenes)
        {
            if (![scene isKindOfClass:[UIWindowScene class]])
                continue;

            UIWindowScene *ws =
                (UIWindowScene *)scene;

            UIInterfaceOrientation orientation =
                ws.interfaceOrientation;

            if (orientation == UIInterfaceOrientationPortrait ||
                orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                return YES;
            }
        }
    }

    return NO;
}

#pragma mark - Original Transform

static CGAffineTransform SHA_OriginalTransform(
    UIView *view
)
{
    if (!view)
        return CGAffineTransformIdentity;

    if (!SHAOriginalTransforms)
    {
        SHAOriginalTransforms =
            [NSMapTable weakToStrongObjectsMapTable];
    }

    NSValue *value =
        [SHAOriginalTransforms objectForKey:view];

    if (value)
        return [value CGAffineTransformValue];

    CGAffineTransform transform =
        view.transform;

    [SHAOriginalTransforms
        setObject:
            [NSValue valueWithCGAffineTransform:transform]
        forKey:view];

    return transform;
}

#pragma mark - Safe Visual Container

static BOOL SHA_HasGestureRecognizers(
    UIView *view
)
{
    if (!view)
        return YES;

    NSArray *gestures =
        view.gestureRecognizers;

    return gestures.count != 0;
}

static BOOL SHA_IsUnsafeContainer(
    UIView *view
)
{
    if (!view)
        return YES;

    NSString *name =
        NSStringFromClass([view class]);

    /*
     * Không bao giờ đụng Home Grabber.
     */
    if ([name isEqualToString:
            @"SBHomeGrabberView"])
    {
        return YES;
    }

    /*
     * Không đụng UIWindow.
     */
    if ([view isKindOfClass:[UIWindow class]])
    {
        return YES;
    }

    /*
     * Không đụng có gesture recognizer.
     */
    if (SHA_HasGestureRecognizers(view))
    {
        return YES;
    }

    return NO;
}

#pragma mark - Home Visual Container

static UIView *SHA_FindHomeVisualContainer(
    UIView *pill
)
{
    if (!pill)
        return nil;

    UIWindow *window =
        pill.window;

    if (!window)
        return nil;

    CGFloat screenWidth =
        CGRectGetWidth(window.bounds);

    UIView *candidate =
        nil;

    UIView *current =
        pill.superview;

    int level = 0;

    while (current &&
           current != window &&
           level < 8)
    {
        level++;

        if (SHA_IsUnsafeContainer(current))
        {
            current =
                current.superview;

            continue;
        }

        CGRect bounds =
            current.bounds;

        CGFloat width =
            CGRectGetWidth(bounds);

        CGFloat height =
            CGRectGetHeight(bounds);

        /*
         * Tìm container visual:
         *
         * - rộng gần bằng màn hình
         * - cao vừa phải
         * - không có gesture
         *
         * Không lấy chính pill.
         */

        if (screenWidth > 0.0 &&
            width >= screenWidth * 0.60 &&
            height >= 20.0 &&
            height <= 180.0)
        {
            candidate =
                current;
        }

        current =
            current.superview;
    }

    return candidate;
}

#pragma mark - Resize Visual Container

static void SHA_ResizeVisualContainer(
    UIView *view,
    CGFloat delta
)
{
    if (!view)
        return;

    if (delta == 0.0)
        return;

    CGRect bounds =
        view.bounds;

    CGFloat oldHeight =
        CGRectGetHeight(bounds);

    if (oldHeight <= 0.0)
        return;

    CGFloat newHeight =
        oldHeight + delta;

    if (newHeight < 1.0)
        newHeight = 1.0;

    /*
     * Giữ tâm theo chiều Y.
     *
     * Chỉ thay visual container.
     */
    CGFloat centerY =
        CGRectGetMidY(bounds);

    bounds.size.height =
        newHeight;

    bounds.origin.y =
        centerY - newHeight / 2.0;

    view.bounds =
        bounds;
}

#pragma mark - Home Bar

%hook MTLumaDodgePillView

- (void)layoutSubviews
{
    %orig;

    SHA_LoadPreferences();

    if (!SHA_IsPortrait())
        return;

    if (SHAHomeDelta == 0.0)
        return;

    UIView *pill =
        (UIView *)self;

    UIView *container =
        SHA_FindHomeVisualContainer(pill);

    if (!container)
        return;

    /*
     * Không đụng pill.
     *
     * Chỉ resize visual container.
     */
    SHA_ResizeVisualContainer(
        container,
        SHAHomeDelta
    );
}

%end

%hook MTStaticColorPillView

- (void)layoutSubviews
{
    %orig;

    SHA_LoadPreferences();

    if (!SHA_IsPortrait())
        return;

    if (SHAHomeDelta == 0.0)
        return;

    UIView *pill =
        (UIView *)self;

    UIView *container =
        SHA_FindHomeVisualContainer(pill);

    if (!container)
        return;

    SHA_ResizeVisualContainer(
        container,
        SHAHomeDelta
    );
}

%end

#pragma mark - Status Bar Container Search

static BOOL SHA_IsStatusClass(
    UIView *view
)
{
    if (!view)
        return NO;

    NSString *name =
        NSStringFromClass([view class]);

    if ([name isEqualToString:@"_UIStatusBar"])
        return YES;

    if ([name isEqualToString:@"UIStatusBar"])
        return YES;

    if ([name isEqualToString:
            @"SBMainDisplaySceneLayoutStatusBarView"])
        return YES;

    return NO;
}

static UIView *SHA_FindStatusContainer(
    UIView *view
)
{
    if (!view)
        return nil;

    UIView *current =
        view;

    int level = 0;

    while (current && level < 6)
    {
        level++;

        NSString *name =
            NSStringFromClass([current class]);

        if ([name containsString:@"StatusBar"])
        {
            /*
             * Không lấy những view quá nhỏ,
             * tránh bắt icon.
             */
            CGFloat width =
                CGRectGetWidth(current.bounds);

            CGFloat height =
                CGRectGetHeight(current.bounds);

            if (width >= 100.0 &&
                height >= 15.0)
            {
                return current;
            }
        }

        current =
            current.superview;
    }

    return nil;
}

#pragma mark - Status Bar

%hook _UIStatusBar

- (void)layoutSubviews
{
    %orig;

    SHA_LoadPreferences();

    if (!SHA_IsPortrait())
        return;

    if (SHAStatusDelta == 0.0)
        return;

    UIView *status =
        (UIView *)self;

    /*
     * Chính _UIStatusBar là container.
     *
     * Resize height thay vì scale icon.
     */
    SHA_ResizeVisualContainer(
        status,
        SHAStatusDelta
    );
}

%end

#pragma mark - SpringBoard Status Container

%hook SBMainDisplaySceneLayoutStatusBarView

- (void)layoutSubviews
{
    %orig;

    SHA_LoadPreferences();

    if (!SHA_IsPortrait())
        return;

    if (SHAStatusDelta == 0.0)
        return;

    UIView *status =
        (UIView *)self;

    SHA_ResizeVisualContainer(
        status,
        SHAStatusDelta
    );
}

%end

#pragma mark - Settings Changed

static void SHA_SettingsChanged(
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
)
{
    SHA_LoadPreferences();

    dispatch_async(
        dispatch_get_main_queue(),
        ^{
            /*
             * Chỉ yêu cầu layout lại.
             */
            UIApplication *app =
                [UIApplication sharedApplication];

            if (!app)
                return;

            if (@available(iOS 13.0, *))
            {
                for (UIScene *scene in
                     app.connectedScenes)
                {
                    if (![scene
                            isKindOfClass:
                                [UIWindowScene class]])
                    {
                        continue;
                    }

                    UIWindowScene *ws =
                        (UIWindowScene *)scene;

                    for (UIWindow *window in
                         ws.windows)
                    {
                        [window setNeedsLayout];
                    }
                }
            }
        }
    );
}

#pragma mark - Constructor

%ctor
{
    @autoreleasepool
    {
        SHAOriginalTransforms =
            [NSMapTable weakToStrongObjectsMapTable];

        SHA_LoadPreferences();

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            SHA_SettingsChanged,
            CFSTR(
                "com.congtu.statushomebaradjuster.settingsChanged"
            ),
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );
    }
}
