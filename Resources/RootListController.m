#import "RootListController.h"

@implementation SCRootListController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root"
                                                 target:self];
    }

    return _specifiers;
}

- (void)respring
{
    pid_t pid = [[NSProcessInfo processInfo] processIdentifier];

    if (pid == 0) {
        return;
    }

    // PreferenceLoader gọi method này từ PSButtonCell.
    // Dùng SpringBoard restart thông qua launchctl.
    system("killall -9 SpringBoard");
}

@end
