#import <UIKit/UIKit.h>

@interface SystemCorner1pxRootListController : UITableViewController
@end

@implementation SystemCorner1pxRootListController

- (NSArray *)specifiers
{
    if (_specifiers == nil)
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

    return _specifiers;
}

@end
