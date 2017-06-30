
#import "AssetHelper.h"

@implementation AssetHelper
+(ALAssetsLibrary *) defaultAssetsLibrary;
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,
                  ^{
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}
@end
