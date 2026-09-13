#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static NSString * const SC16RadiusKey = @"SystemCornerRadius";

static BOOL SC16Enabled(void)
{
    NSString *version = UIDevice.currentDevice.systemVersion;

    // Chỉ hoạt động trên iOS 16.4
    if (![version hasPrefix:@"16.4"]) {
        return NO;
    }

    NSNumber *enabled =
        [[NSUserDefaults standardUserDefaults]
            objectForKey:@"SC16Enabled"];

    return enabled ? enabled.boolValue : YES;
}

static CGFloat SC16CornerRadius(void)
{
    NSNumber *value =
        [[NSUserDefaults standardUserDefaults]
            objectForKey:SC16RadiusKey];

    if (!value) {
        return 1.0;
    }

    CGFloat radius = value.doubleValue;

    // Không cho giá trị âm
    if (radius < 0.0) {
        radius = 0.0;
    }

    // Giới hạn để tránh giá trị bất thường
    if (radius > 100.0) {
        radius = 100.0;
    }

    return radius;
}


%hook UIScreen

- (CGFloat)_displayCornerRadius
{
    if (SC16Enabled()) {
        return SC16CornerRadius();
    }

    return %orig;
}

- (UIEdgeInsets)_sceneSafeAreaInsets
{
    if (SC16Enabled()) {
        return UIEdgeInsetsZero;
    }

    return %orig;
}

%end


%hook UITraitCollection

- (CGFloat)displayCornerRadius
{
    if (SC16Enabled()) {
        return SC16CornerRadius();
    }

    return %orig;
}

- (CGFloat)_displayCornerRadius
{
    if (SC16Enabled()) {
        return SC16CornerRadius();
    }

    return %orig;
}

+ (instancetype)traitCollectionWithDisplayCornerRadius:(CGFloat)radius
{
    if (SC16Enabled()) {
        return %orig(SC16CornerRadius());
    }

    return %orig(radius);
}

%end


%ctor
{
    @autoreleasepool {

        if (SC16Enabled()) {
            NSLog(
                @"[SystemCorner] Loaded - iOS %@ - Radius: %.2f",
                UIDevice.currentDevice.systemVersion,
                SC16CornerRadius()
            );
        }
    }
}
