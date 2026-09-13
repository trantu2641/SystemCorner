#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CoreFoundation.h>

static NSString * const SC1_PREFS_ID = @"com.tutu.systemcorner1px";
static CGFloat const SC1_DEFAULT_RADIUS = 1.0;

static BOOL SC1Enabled(void)
{
    return [UIDevice.currentDevice.systemVersion hasPrefix:@"16."];
}

static BOOL SC1IsSystemProcess(void)
{
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
    if (!bundleID)
        return NO;

    return [bundleID isEqualToString:@"com.apple.springboard"] ||
           [bundleID isEqualToString:@"com.apple.Preferences"] ||
           [bundleID hasPrefix:@"com.apple."];
}

static CGFloat SC1CornerRadius(void)
{
    CFPropertyListRef value =
        CFPreferencesCopyAppValue(
            CFSTR("CornerRadius"),
            (__bridge CFStringRef)SC1_PREFS_ID
        );

    CGFloat radius = SC1_DEFAULT_RADIUS;

    if (value && CFGetTypeID(value) == CFNumberGetTypeID())
    {
        double number = SC1_DEFAULT_RADIUS;
        if (CFNumberGetValue((CFNumberRef)value,
                             kCFNumberDoubleType,
                             &number))
            radius = (CGFloat)number;
    }

    if (value)
        CFRelease(value);

    if (radius < 0.0) radius = 0.0;
    if (radius > 20.0) radius = 20.0;

    return radius;
}

static void SC1ApplyLayer(CALayer *layer)
{
    if (!layer || layer.cornerRadius <= 0.0)
        return;

    layer.cornerRadius = SC1CornerRadius();
}

%hook UIView

- (void)didMoveToWindow
{
    %orig;

    if (!SC1Enabled() || !SC1IsSystemProcess())
        return;

    SC1ApplyLayer(self.layer);
}

- (void)layoutSubviews
{
    %orig;

    if (!SC1Enabled() || !SC1IsSystemProcess())
        return;

    SC1ApplyLayer(self.layer);
}

%end
