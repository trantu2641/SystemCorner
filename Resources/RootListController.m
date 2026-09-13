#import "RootListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTextFieldSpecifier.h>

static NSString *const SCPreferenceDomain = @"com.trantu2641.systemcorner";

@implementation RootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if (!key) return;

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferenceDomain];
    [defaults setObject:value forKey:key];
    [defaults synchronize];

    [super setPreferenceValue:value specifier:specifier];

    if ([key isEqualToString:@"CornerRadius"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SystemCornerPreferencesChanged"
                                                                object:nil];
        });
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:SCPreferenceDomain];
    id value = [defaults objectForKey:key];

    if (!value && [key isEqualToString:@"CornerRadius"]) {
        return @1;
    }

    return value;
}

@end
