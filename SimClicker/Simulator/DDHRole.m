//  Created by Dominik Hauser on 29.05.25.
//  
//


#import "DDHRole.h"

NSString * const AXRoleName[] = {
    [AXRoleUnsupported] = @"Unsupported",
    [AXRoleAXButton] = @"AXButton",
    [AXRoleAXStaticText] = @"AXStaticText",
    [AXRoleAXImage] = @"AXImage",
    [AXRoleAXHeading] = @"AXHeading",
    [AXRoleToolbar] = @"AXToolbar",
    [AXRoleMenuBar] = @"AXMenuBar",
    [AXRoleMenuBarItem] = @"AXMenuBarItem",
};

NSString * const AXRoleCode[] = {
    [AXRoleUnsupported] = @"unsupported",
    [AXRoleAXButton] = @"buttons",
    [AXRoleAXStaticText] = @"staticTexts",
    [AXRoleAXImage] = @"images",
    [AXRoleAXHeading] = @"staticTexts",
    [AXRoleToolbar] = @"unsupported",
    [AXRoleMenuBar] = @"unsupported",
    [AXRoleMenuBarItem] = @"unsupported",
};

@interface DDHRole ()
@property (nonatomic) AXRole role;
@end

@implementation DDHRole
- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        if ([name isEqualToString:AXRoleName[AXRoleAXButton]]) {
            _role = AXRoleAXButton;
        } else if ([name isEqualToString:AXRoleName[AXRoleAXStaticText]]) {
            _role = AXRoleAXStaticText;
        } else if ([name isEqualToString:AXRoleName[AXRoleAXImage]]) {
            _role = AXRoleAXImage;
        } else if ([name isEqualToString:AXRoleName[AXRoleAXHeading]]) {
            _role = AXRoleAXHeading;
        } else if ([name isEqualToString:AXRoleName[AXRoleToolbar]]) {
            _role = AXRoleToolbar;
        } else if ([name isEqualToString:AXRoleName[AXRoleMenuBar]]) {
            _role = AXRoleMenuBar;
        } else if ([name isEqualToString:AXRoleName[AXRoleMenuBarItem]]) {
            _role = AXRoleMenuBarItem;
        } else {
            NSLog(@">>> Unsupported role name: %@", name);
            _role = AXRoleUnsupported;
        }
    }
    return self;
}

- (NSString *)code {
    return [NSString stringWithFormat:@"app.%@", AXRoleCode[self.role]];
}

- (NSString *)name {
    return AXRoleName[self.role];
}

@end
