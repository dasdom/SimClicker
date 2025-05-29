//  Created by Dominik Hauser on 29.05.25.
//  
//


#import "DDHSimulatorManager.h"
#import <AppKit/AppKit.h>
#import "DDHOverlayElement.h"
#import "UIElementUtilities.h"
#import "DDHRole.h"

@interface DDHSimulatorManager ()
@property (nonatomic) CGSize spacing;
@property (nonatomic, strong) NSArray<NSString *> *possibleTags;
@end

@implementation DDHSimulatorManager
- (instancetype)initWithPossibleCharacters:(NSArray<NSString *> *)possibleCharacters {
    if (self = [super init]) {
        NSArray<NSRunningApplication *> *applications = [[NSWorkspace sharedWorkspace] runningApplications];
        NSMutableArray<NSString *> *names = [[NSMutableArray alloc] init];
        NSMutableArray<NSRunningApplication *> *simulators = [[NSMutableArray alloc] init];
        for (NSRunningApplication *application in applications) {
            if ([application.bundleIdentifier isEqualToString:@"com.apple.iphonesimulator"]) {
                NSLog(@"simulator: %@", application);

                [simulators addObject:application];

                [names addObject:application.localizedName];
            }
        }

        NSRunningApplication *simulator = simulators.firstObject;
        self.simulatorRef = AXUIElementCreateApplication(simulator.processIdentifier);
        self.simulator = simulator;
        NSLog(@"applicationRef: %@", self.simulatorRef);

        self.spacing = CGSizeMake(15, 15);
        self.possibleTags = [self generatePossibleTagsWithPossibleCharacters:possibleCharacters];

    }
    return self;
}

- (NSArray<NSString *> *)generatePossibleTagsWithPossibleCharacters:(NSArray<NSString *> *)possibleCharacters {
    NSArray<NSString *> *characters = possibleCharacters;
    NSMutableArray<NSString *> *possibleTags = [[NSMutableArray alloc] init];
    for (NSString *c1 in characters) {
        for (NSString *c2 in characters) {
            NSString *tag = [NSString stringWithFormat:@"%@%@", c1, c2];
            [possibleTags addObject:tag];
        }
    }
    return [possibleTags copy];
}

- (NSRect)simulatorWindowFrame {
    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:self.simulatorRef];

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];

        if ([role isEqualToString:@"AXWindow"]) {
            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
            return frame;
        }
    }
    return NSZeroRect;
}

- (NSArray<DDHOverlayElement *> *)overlayChildren {
    NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:self.simulatorRef index:0];

    for (NSInteger i = 0; i < [overlayElements count]; i++) {
        DDHOverlayElement *overlayElement = overlayElements[i];
        overlayElement.tag = self.possibleTags[i];

        NSLog(@"%@, %@, %@", overlayElement.tag, overlayElement.role, [NSValue valueWithRect:overlayElement.frame]);
    }

    return overlayElements;
}

- (NSArray<DDHOverlayElement *> *)overlayChildrenOfUIElement:(AXUIElementRef)element index:(NSInteger)index {
    NSMutableArray<DDHOverlayElement *> *tempOverlayElements = [[NSMutableArray alloc] init];

    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:element];

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *roleName = [UIElementUtilities roleOfUIElement:uiElement];
//                NSString *description = [UIElementUtilities descriptionOfAXDescriptionOfUIElement:uiElement];
//                NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
//                NSLog(@"%@ %@, role: %@, %@", child, role, description, [NSValue valueWithRect:frame]);

        if ([roleName isEqualToString:@"AXGroup"]) {
            NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:uiElement index:index + 1];
            [tempOverlayElements addObjectsFromArray:overlayElements];

            if (overlayElements.count < 1) {
                NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
                NSArray<DDHOverlayElement *> *overlayElements = [self scanForUIElementsInFrame:frame];
                [tempOverlayElements addObjectsFromArray:overlayElements];
            }
        } else if ([roleName isEqualToString:@"AXToolbar"] ||
                   [roleName isEqualToString:@"AXMenuBar"]) {
            NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:uiElement index:index + 1];
            [tempOverlayElements addObjectsFromArray:overlayElements];

            if (overlayElements.count < 1) {
                NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
                NSArray<DDHOverlayElement *> *overlayElements = [self scanForUIElementsInFrame:frame];
                [tempOverlayElements addObjectsFromArray:overlayElements];
            }

            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];

            NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:uiElement];
            NSString *tag = [NSString stringWithFormat:@"%ld%ld", (long)index, (long)i];
            DDHRole *role = [[DDHRole alloc] initWithName:roleName];
            DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:child frame:frame role:role actionNames:actionNames tag:tag];
            [tempOverlayElements addObject:overlayElement];
        } else if ([roleName isEqualToString:@"AXWindow"]) {
//            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
            //            NSLog(@"simulator frame: %@", [NSValue valueWithRect:frame]);

            NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:uiElement index:index + 1];
            [tempOverlayElements addObjectsFromArray:overlayElements];

        } else {
            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];

            NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:uiElement];
            NSString *tag = [NSString stringWithFormat:@"%ld%ld", (long)index, (long)i];
            DDHRole *role = [[DDHRole alloc] initWithName:roleName];
            DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:child frame:frame role:role actionNames:actionNames tag:tag];
            [tempOverlayElements addObject:overlayElement];
        }
    }

    return [tempOverlayElements copy];
}

- (NSArray<DDHOverlayElement *> *)overlayElementsFromStartElement:(AXUIElementRef)element index:(NSInteger)index {
    NSMutableArray<DDHOverlayElement *> *tempOverlayElements = [[NSMutableArray alloc] init];

    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:element];

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];

        if ([role isEqualToString:@"AXWindow"]) {
            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
            NSLog(@"simulator frame: %@", [NSValue valueWithRect:frame]);

            NSArray<DDHOverlayElement *> *overlayElements = [self scanForUIElementsInFrame:frame];
            [tempOverlayElements addObjectsFromArray:overlayElements];

            break;
        }
    }

    return [tempOverlayElements copy];
}

- (NSArray<DDHOverlayElement *> *)scanForUIElementsInFrame:(CGRect)frame {
    NSMutableArray<DDHOverlayElement *> *tempOverlayElements = [[NSMutableArray alloc] init];

    NSInteger tagInt = 0;
    CGFloat y = frame.origin.y;

    //    NSLog(@"scanForUIElementsInFrame frame: %@", [NSValue valueWithRect:frame]);

    NSMutableSet<NSString *> *identifierArray = [[NSMutableSet alloc] init];
    AXUIElementRef previousElement = NULL;

    while (y < CGRectGetMaxY(frame)) {
        CGFloat x = frame.origin.x;
        while (x < CGRectGetMaxX(frame)) {
            NSPoint cocoaPoint = CGPointMake(x, y);
            CGPoint pointAsCGPoint = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:cocoaPoint];

            //            CGPoint pointAsCGPoint = CGPointMake(x, y);
            //            NSLog(@"pointAsCGPoint: %lf %lf", x, y);

            AXUIElementRef newElement = NULL;
            if (AXUIElementCopyElementAtPosition(self.simulatorRef, pointAsCGPoint.x, pointAsCGPoint.y, &newElement) == kAXErrorSuccess
                && newElement
                && (previousElement == NULL || NO == CFEqual(previousElement, newElement))) {

                NSString *roleName = [UIElementUtilities roleOfUIElement:newElement];
                NSRect frame = [UIElementUtilities frameOfUIElement:newElement];

                //                NSString *description = [UIElementUtilities descriptionOfAXDescriptionOfUIElement:newElement];
                NSString *identifier = [NSString stringWithFormat:@"%@", [NSValue valueWithRect:frame]];
                //                NSLog(@"%@ %@, role: %@, %@", newElement, role, description, [NSValue valueWithRect:frame]);

                if (NO == [roleName isEqualToString:@"AXGroup"]) {

                    if (NO == [identifierArray containsObject:identifier]) {
                        previousElement = newElement;
                        [identifierArray addObject:identifier];
                        NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:newElement];
                        NSString *tag = self.possibleTags[tagInt];
                        DDHRole *role = [[DDHRole alloc] initWithName:roleName];
                        //                        NSLog(@"tag: %@", tag);
                        DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:(__bridge NSValue *)newElement frame:frame role:role actionNames:actionNames tag:tag];
                        [tempOverlayElements addObject:overlayElement];
                        tagInt++;
                    }
                } else {
                    previousElement = newElement;
                }

                //                if ([role isEqualToString:@"AXButton"] ||
                //                    [role isEqualToString:@"AXTextField"]) {
                x += frame.size.width;
                //                } else {
                //                    x += self.spacing.width;
                //                }
            } else {
                x += self.spacing.width;
            }
        }
        y += self.spacing.height;
    }

    return [tempOverlayElements copy];
}
@end
