#import <Preferences/PSListController.h>

@interface SCRootListController : PSListController
@end

@implementation SCRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root"
												 target:self];
	}

	return _specifiers;
}

@end
