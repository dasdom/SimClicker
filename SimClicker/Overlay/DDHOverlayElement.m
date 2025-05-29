//  Created by Dominik Hauser on 10.05.25.
//  
//


#import "DDHOverlayElement.h"
#import "DDHRole.h"

@implementation DDHOverlayElement
- (instancetype)initWithUIElementValue:(NSValue *)uiElementValue frame:(NSRect)frame role:(DDHRole *)role actionNames:(NSArray<NSString *> *)actionNames tag:(NSString *)tag {
    if (self = [super init]) {
        _uiElementValue = uiElementValue;
        _frame = frame;
        _role = role;
        _actionNames = actionNames;
        _tag = tag;
    }
    return self;
}
@end
