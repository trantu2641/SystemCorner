#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <notify.h>

static NSString * const SCPreferenceDomain = @"xyz.cypwn.systemcorner";

static CGFloat SCRadius(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferenceDomain];

    NSNumber *value = [defaults objectForKey:@"SCRadius"];

    if (!value) {
        return 1.0;
    }

    CGFloat radius = [value doubleValue];

    if (radius < 0.0) {
        radius = 0.0;
    }

    if (radius > 100.0) {
        radius = 100.0;
    }

    return radius;
}

static BOOL SCEnabled(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferenceDomain];

    NSNumber *value = [defaults objectForKey:@"SCEnabled"];

    return value ? [value boolValue] : YES;
}

static void SCSettingsChanged(void) {
    NSLog(@"[SystemCorner] Settings changed - enabled=%d radius=%.2f",
          SCEnabled(),
          SCRadius());
}

%hook UIScreen

- (CGFloat)_displayCornerRadius {
    if (SCEnabled()) {
        return SCRadius();
    }

    return %orig;
}

%end


%hook UITraitCollection

- (CGFloat)displayCornerRadius {
    if (SCEnabled()) {
        return SCRadius();
    }

    return %orig;
}

- (CGFloat)_displayCornerRadius {
    if (SCEnabled()) {
        return SCRadius();
    }

    return %orig;
}

- (instancetype)traitCollectionWithDisplayCornerRadius:(CGFloat)radius {
    if (SCEnabled()) {
        return %orig(SCRadius());
    }

    return %orig(radius);
}

%end


%ctor {
    @autoreleasepool {

        int token = 0;

        notify_register_dispatch(
            "xyz.cypwn.systemcorner.settingsChanged",
            &token,
            dispatch_get_main_queue(),
            ^(int unused) {
                SCSettingsChanged();
            }
        );

        NSLog(@"[SystemCorner] Loaded - enabled=%d radius=%.2f",
              SCEnabled(),
              SCRadius());
    }
}
