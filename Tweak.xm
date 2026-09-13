#import <UIKit/UIKit.h>

static CGFloat SCRadius(void) {
    NSNumber *value = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"SCRadius"];

    if (!value) {
        return 1.0;
    }

    CGFloat radius = value.doubleValue;

    if (radius < 0.0)
        radius = 0.0;

    if (radius > 100.0)
        radius = 100.0;

    return radius;
}

static BOOL SCEnabled(void) {
    NSNumber *value = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"SCEnabled"];

    return value ? value.boolValue : YES;
}

%hook UIScreen

- (CGFloat)_displayCornerRadius {
    return SCEnabled() ? SCRadius() : %orig;
}

%end

%hook UITraitCollection

- (CGFloat)displayCornerRadius {
    return SCEnabled() ? SCRadius() : %orig;
}

- (CGFloat)_displayCornerRadius {
    return SCEnabled() ? SCRadius() : %orig;
}

- (instancetype)traitCollectionWithDisplayCornerRadius:(CGFloat)radius {
    return SCEnabled() ? %orig(SCRadius()) : %orig(radius);
}

%end

%ctor {
    @autoreleasepool {
        NSLog(@"[SystemCorner] Loaded - enabled=%d radius=%.2f",
              SCEnabled(), SCRadius());
    }
}
