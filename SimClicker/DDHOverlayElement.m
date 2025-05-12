//  Created by Dominik Hauser on 10.05.25.
//  
//


#import "DDHOverlayElement.h"

@implementation DDHOverlayElement
- (instancetype)initWithUIElementValue:(NSValue *)uiElementValue tag:(NSString *)tag {
    if (self = [super init]) {
        _uiElementValue = uiElementValue;
        _tag = tag;
    }
    return self;
}
@end
