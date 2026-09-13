#import "RootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation RootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];

    if (!key) {
        return nil;
    }

    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (value == nil) {
        value = [specifier propertyForKey:@"default"];
    }

    return value;
}

- (void)setPreferenceValue:(id)value
              forSpecifier:(PSSpecifier *)specifier {

    NSString *key = [specifier propertyForKey:@"key"];

    if (!key) {
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (value) {
        [defaults setObject:value forKey:key];
    } else {
        [defaults removeObjectForKey:key];
    }

    [defaults synchronize];

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("xyz.cypwn.systemcorner.settingsChanged"),
        NULL,
        NULL,
        YES
    );
}

- (void)respring:(id)sender {
    pid_t pid;

    const char *args[] = {
        "killall",
        "-9",
        "SpringBoard",
        NULL
    };

    posix_spawn(
        &pid,
        "/usr/bin/killall",
        NULL,
        NULL,
        (char *const *)args,
        NULL
    );
}

@end
