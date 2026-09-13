#import <UIKit/UIKit.h>

static NSString *const SCPreferenceDomain = @"com.trantu2641.systemcorner";
static CGFloat SCReadRadius(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferenceDomain];
    NSNumber *value = [defaults objectForKey:@"CornerRadius"];
    if (!value) return 1.0;

    CGFloat radius = value.doubleValue;
    if (radius < 0.0) radius = 0.0;
    if (radius > 100.0) radius = 100.0;
    return radius;
}

%hook UIScreen

- (CGFloat)_displayCornerRadius {
    return SCReadRadius();
}

%end

%hook UITraitCollection

- (CGFloat)displayCornerRadius {
    return SCReadRadius();
}

- (CGFloat)_displayCornerRadius {
    return SCReadRadius();
}

- (instancetype)traitCollectionWithDisplayCornerRadius:(CGFloat)radius {
    return %orig(SCReadRadius());
}

%end

%ctor {
    @autoreleasepool {
        NSLog(@"[SystemCorner] loaded, radius=%g", SCReadRadius());
    }
}
