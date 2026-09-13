#import "RootListController.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@implementation RootListController

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root"
                                                  target:self];
    }

    return _specifiers;
}

@end
