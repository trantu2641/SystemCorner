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

        return value ?: @1;
    }

    if ([key isEqualToString:@"SCEnabled"]) {
        NSNumber *value = [[NSUserDefaults standardUserDefaults]
            objectForKey:@"SCEnabled"];

        return value ?: @YES;
    }

    return [super readPreferenceValue:specifier];
}

- (void)setPreferenceValue:(id)value
                   specifier:(PSSpecifier *)specifier {

    NSString *key = [specifier propertyForKey:@"key"];

    if (!key.length) {
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
}

@end
