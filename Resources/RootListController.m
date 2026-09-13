#import <Preferences/PSListController.h>

@interface RootListController : PSListController
@end

@implementation RootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"root"
                                                  target:self];
    }

    return _specifiers;
}

@end
