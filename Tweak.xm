#import <UIKit/UIKit.h>

static CGFloat SCRadius(void) {
    NSNumber *value = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"SCRadius"];

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

static BOOL SCEnabled(void) {
    NSNumber *value = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"SCEnabled"];

    return value ? value.boolValue : YES;
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
        if (SCEnabled()) {
            NSLog(@"[SystemCorner] Loaded - radius: %.2f", SCRadius());
        }
    }
}
