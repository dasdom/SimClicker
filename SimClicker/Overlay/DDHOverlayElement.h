//  Created by Dominik Hauser on 10.05.25.
//  
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHRole;

@interface DDHOverlayElement : NSObject
@property (nonatomic, strong) NSValue *uiElementValue;
@property (nonatomic) NSRect frame;
@property (nonatomic, strong) DDHRole *role;
@property (nonatomic, strong) NSArray<NSString *> *actionNames;
@property (nonatomic, strong) NSString *tag;
- (instancetype)initWithUIElementValue:(NSValue *)uiElementValue frame:(NSRect)frame role:(DDHRole *)role actionNames:(NSArray<NSString *> *)actionNames tag:(NSString *)tag;
@end

NS_ASSUME_NONNULL_END
