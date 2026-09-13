#import "RootListController.h"
#import <Preferences/PSSpecifier.h>

@interface RootListController ()

@end

@implementation RootListController

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root"
                                                  target:self];
    }

    return _specifiers;
}

@end
