//  Created by Dominik Hauser on 10.05.25.
//  
//


#import "DDHOverlayElement.h"

@implementation DDHOverlayElement
- (instancetype)initWithUIElementValue:(NSValue *)uiElementValue frame:(NSRect)frame tag:(NSString *)tag {
    if (self = [super init]) {
        _uiElementValue = uiElementValue;
        _frame = frame;
        _tag = tag;
    }
    return self;
}
@end
