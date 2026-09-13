#import <UIKit/UIKit.h>

static NSUserDefaults *SCDefaults(void) {
    return [[NSUserDefaults alloc]
        initWithSuiteName:@"com.trantu2641.systemcorner"];
}

static BOOL SCEnabled(void) {
    NSNumber *value = [SCDefaults() objectForKey:@"SCEnabled"];
    return value ? value.boolValue : YES;
}

static CGFloat SCRadius(void) {
    NSNumber *value = [SCDefaults() objectForKey:@"SCRadius"];

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
        NSLog(@"[SystemCorner] Loaded");
        NSLog(@"[SystemCorner] Enabled=%d Radius=%.2f",
              SCEnabled(), SCRadius());
    }
}
