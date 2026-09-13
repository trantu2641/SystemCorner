#import "RootListController.h"
#import <Preferences/Preferences.h>

@implementation RootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];

    if ([key isEqualToString:@"SCRadius"]) {
        NSNumber *value = [[NSUserDefaults standardUserDefaults]
            objectForKey:@"SCRadius"];

        if (!value) {
            return @1;
        }

        return value;
    }

    if ([key isEqualToString:@"SCEnabled"]) {
        NSNumber *value = [[NSUserDefaults standardUserDefaults]
            objectForKey:@"SCEnabled"];

        if (!value) {
            return @YES;
        }

        return value;
    }

    return [super readPreferenceValue:specifier];
}

- (void)setPreferenceValue:(id)value
                   specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];

    if (key.length == 0) {
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

    CFPreferencesSetAppValue(
        (__bridge CFStringRef)key,
        (__bridge CFPropertyListRef)value,
        CFSTR("xyz.cypwn.systemcorner")
    );

    CFPreferencesAppSynchronize(
        CFSTR("xyz.cypwn.systemcorner")
    );

    if ([key isEqualToString:@"SCRadius"] ||
        [key isEqualToString:@"SCEnabled"]) {

        notify_post("xyz.cypwn.systemcorner.settingsChanged");
    }
}

@end
