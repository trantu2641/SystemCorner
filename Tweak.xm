#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

static CGFloat SCRadius(void) {
    CFPropertyListRef value = CFPreferencesCopyAppValue(
        CFSTR("SCRadius"),
        CFSTR("xyz.cypwn.systemcorner")
    );

    CGFloat radius = 1.0;

    if (value && CFGetTypeID(value) == CFNumberGetTypeID()) {
        double number = 1.0;
        CFNumberGetValue(
            (CFNumberRef)value,
            kCFNumberDoubleType,
            &number
        );
        radius = number;
    }

    if (value) {
        CFRelease(value);
    }

    if (radius < 0.0)
        radius = 0.0;

    if (radius > 100.0)
        radius = 100.0;

    return radius;
}

static BOOL SCEnabled(void) {
    CFPropertyListRef value = CFPreferencesCopyAppValue(
        CFSTR("SCEnabled"),
        CFSTR("xyz.cypwn.systemcorner")
    );

    BOOL enabled = YES;

    if (value && CFGetTypeID(value) == CFBooleanGetTypeID()) {
        enabled = CFBooleanGetValue((CFBooleanRef)value);
    }

    if (value) {
        CFRelease(value);
    }

    return enabled;
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
            NSLog(
                @"[SystemCorner] Loaded - radius: %.2f",
                SCRadius()
            );
        }
    }
}
