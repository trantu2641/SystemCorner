#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat const SC1_CORNER_RADIUS = 1.0;

static BOOL SC1Enabled(void)
{
    return [UIDevice.currentDevice.systemVersion hasPrefix:@"16."];
}

/*
 * Chỉ chạy trong các tiến trình UI hệ thống.
 * Không đụng ứng dụng thông thường.
 */
static BOOL SC1IsSystemProcess(void)
{
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;

    if (!bundleID)
        return NO;

    return [bundleID isEqualToString:@"com.apple.springboard"] ||
           [bundleID isEqualToString:@"com.apple.Preferences"] ||
           [bundleID hasPrefix:@"com.apple."];
}

/*
 * Chỉ đổi những layer vốn đã có corner radius.
 * Không thay frame, bounds, transform, position hoặc mask.
 */
static void SC1ApplyLayer(CALayer *layer)
{
    if (!layer)
        return;

    if (layer.cornerRadius <= 0.0)
        return;

    layer.cornerRadius = SC1_CORNER_RADIUS;
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
