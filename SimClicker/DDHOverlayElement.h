//  Created by Dominik Hauser on 10.05.25.
//  
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHOverlayElement : NSObject
@property (nonatomic, strong) NSValue *uiElementValue;
@property (nonatomic, strong) NSString *tag;
- (instancetype)initWithUIElementValue:(NSValue *)uiElementValue tag:(NSString *)tag;
@end

NS_ASSUME_NONNULL_END
