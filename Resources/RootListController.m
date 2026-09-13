#import "RootListController.h"
#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import <notify.h>

@implementation RootListController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root"
                                                 target:self];
    }

    return _specifiers;
}

- (void)applySettings
{
    NSUserDefaults *defaults =
        [[NSUserDefaults alloc] initWithSuiteName:@"xyz.cypwn.systemcorner"];

    [defaults synchronize];

    notify_post("xyz.cypwn.systemcorner.settingsChanged");
}

@end
