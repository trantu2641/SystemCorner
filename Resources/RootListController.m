#import "RootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation RootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root"
                                                 target:self];
    }

    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    CFPreferencesAppSynchronize(
        CFSTR("com.trantu2641.systemcorner")
    );
}

@end
