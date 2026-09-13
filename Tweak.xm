#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static BOOL SCEnabled(void) {
    NSString *version = UIDevice.currentDevice.systemVersion;

    if (![version hasPrefix:@"16.4"]) {
        return NO;
    }

    NSNumber *value = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"SC16Enabled"];

    return value ? value.boolValue : YES;
}

static CGFloat SCCornerRadius(void) {
    NSNumber *value = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"SCCornerRadius"];

    if (!value) {
        return 1.0;
    }

    CGFloat radius = value.doubleValue;

    if (radius < 0.0) {
        radius = 0.0;
    }

    if (radius > 100.0) {
        radius = 100.0;
    }

    return radius;
}

%hook UIScreen

- (CGFloat)_displayCornerRadius {
    if (SCEnabled()) {
        return SCCornerRadius();
    }

    return %orig;
}

- (UIEdgeInsets)_sceneSafeAreaInsets {
    if (SCEnabled()) {
        return UIEdgeInsetsZero;
    }

    return %orig;
}

%end

%hook UITraitCollection

- (CGFloat)displayCornerRadius {
    if (SCEnabled()) {
        return SCCornerRadius();
    }

    return %orig;
}

- (CGFloat)_displayCornerRadius {
    if (SCEnabled()) {
        return SCCornerRadius();
    }

    return %orig;
}

+ (instancetype)traitCollectionWithDisplayCornerRadius:(CGFloat)radius {
    if (SCEnabled()) {
        return %orig(SCCornerRadius());
    }

    return %orig(radius);
}

%end

%ctor {
    @autoreleasepool {
        if (SCEnabled()) {
            NSLog(@"[SystemCorner] Loaded - radius: %.2fpx",
                  SCCornerRadius());
        }
    }
}
