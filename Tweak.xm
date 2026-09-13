#import <UIKit/UIKit.h>

static NSString * const SCPreferencesDomain = @"xyz.cypwn.systemcorner";

static BOOL SCEnabled(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferencesDomain];

    NSNumber *value = [defaults objectForKey:@"SCEnabled"];

    if (value == nil) {
        return YES;
    }

    return value.boolValue;
}

static CGFloat SCRadius(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferencesDomain];

    NSNumber *value = [defaults objectForKey:@"SCRadius"];

    if (value == nil) {
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
