//  Created by Dominik Hauser on 09.05.25.
//
//


#import "AppDelegate.h"
#import <AppKit/NSAccessibility.h>
#import "DDHInfoViewController.h"
#import "DDHOverlayWindowController.h"
#import "UIElementUtilities.h"
#import "DDHOverlayElement.h"

@interface AppDelegate ()
@property (nonatomic, strong) DDHOverlayWindowController *overlayWindowController;
@property (nonatomic, strong) DDHInfoViewController *infoViewController;
@property (nonatomic) AXUIElementRef simulatorRef;
@property (nonatomic, strong) NSArray<DDHOverlayElement *> *overlayElements;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [self checkAccessibility];

    [self findSimulators];

    [self showOverlays];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

// MARK: -
- (DDHOverlayWindowController *)overlayWindowController {
    if (nil == _overlayWindowController) {
        _overlayWindowController = [[DDHOverlayWindowController alloc] init];
    }
    return _overlayWindowController;
}

- (void)checkAccessibility {
    if (NO == AXIsProcessTrusted()) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"SimClicker requires Accessibility enabled.";
        alert.informativeText = @"Would you like to launch System Preferences so you can turn on Accessibility access?";
        [alert addButtonWithTitle:@"Open System Preferences"];
        [alert addButtonWithTitle:@"Quit SimClicker"];

        NSInteger alertResult = [alert runModal];

        switch (alertResult) {
            case NSAlertFirstButtonReturn: {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSSystemDomainMask, YES);
                if ([paths count] > 0) {
                    NSURL *prefPaneURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
                    [[NSWorkspace sharedWorkspace] openURL:prefPaneURL];
                }
            }
                break;

            case NSAlertSecondButtonReturn:
                [NSApp terminate:self];
                break;
            default:
                break;
        }
    }
}

- (void)findSimulators {
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
    NSLog(@"applicationRef: %@", self.simulatorRef);

    NSWindow *window = NSApplication.sharedApplication.orderedWindows.firstObject;

    DDHInfoViewController *infoViewController = (DDHInfoViewController *)window.contentViewController;
    infoViewController.inputHandler = ^(NSString * _Nonnull input) {

        NSLog(@"input: %@", input);

        NSUInteger index = [self.overlayElements indexOfObjectPassingTest:^BOOL(DDHOverlayElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.tag isEqualToString:input];
        }];
        if (index == NSNotFound) {
            return;
        }
        [self.overlayWindowController reset];

        AXUIElementRef element = (__bridge AXUIElementRef)self.overlayElements[index].uiElementValue;
        pid_t pid = 0;
        if ((pid = [UIElementUtilities processIdentifierOfUIElement:element])) {
            // pull the target app forward
            NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
            if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
                // perform the action
                [UIElementUtilities performAction:@"AXPress" ofUIElement:element];
            }
        }

        NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
        [currentApplication activateWithOptions:NSApplicationActivateAllWindows];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showOverlays];
        });
    };
    infoViewController.reloadHandler = ^{
        [self showOverlays];
    };

    [infoViewController updateSimulatorPickerWithNames:names];
    self.infoViewController = infoViewController;

    [window makeFirstResponder:infoViewController];
}

- (void)showOverlays {

    [self.overlayWindowController showWindow:nil];

    self.overlayElements = [self overlayChildrenOfUIElement:self.simulatorRef index:0];

    [self.overlayWindowController addOverlays:self.overlayElements];

    NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
    [currentApplication activateWithOptions:NSApplicationActivateAllWindows];
}

- (NSArray<DDHOverlayElement *> *)overlayChildrenOfUIElement:(AXUIElementRef)element index:(NSInteger)index {
    NSMutableArray<DDHOverlayElement *> *tempOverlayElements = [[NSMutableArray alloc] init];

//    NSArray *attributeNames = [UIElementUtilities attributeNamesOfUIElement:element];
//    NSLog(@"attributeNames: %@", attributeNames);

    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:element];
//    NSLog(@"children: %@", children);

    if (children.count < 1) {
        NSLog(@">>> -----------------------------------------------------");
        NSLog(@"NO CHILDREN");
        NSString *role = [UIElementUtilities roleOfUIElement:element];
        NSRect frame = [UIElementUtilities frameOfUIElement:element];
        NSLog(@"%@, role: %@, %@", element, role, [NSValue valueWithRect:frame]);

        NSArray *lineage = [UIElementUtilities lineageOfUIElement:element];
        NSLog(@"lineage: %@", lineage);

        NSString *description = [UIElementUtilities stringDescriptionOfUIElement:element];
        NSLog(@"description: %@", description);
        NSLog(@"<<< -----------------------------------------------------");
    }

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];
//        NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
//        NSLog(@"%@, role: %@, %@", child, role, [NSValue valueWithRect:frame]);

        if ([role isEqualToString:@"AXButton"] ||
            [role isEqualToString:@"AXTextField"] ||
            [role isEqualToString:@"AXStaticText"]) {

            NSString *tag = [NSString stringWithFormat:@"%ld%ld", (long)index, (long)i];
            NSLog(@"tag: %@", tag);
            DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:child tag:tag];
            [tempOverlayElements addObject:overlayElement];
        } else if ([role isEqualToString:@"AXGroup"]
//                   || [role isEqualToString:@"AXToolbar"]
                   ) {
//            NSLog(@">>> %ld", (long)index);
            NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:uiElement index:++index];
            [tempOverlayElements addObjectsFromArray:overlayElements];

            if (overlayElements.count < 1) {
                NSString *tag = [NSString stringWithFormat:@"%ld%ld", (long)index, (long)i];
                //            NSLog(@"tag: %@", tag);
                DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:child tag:tag];
                [tempOverlayElements addObject:overlayElement];
            }

//            NSLog(@"<<< %ld", (long)index);
        } else if ([role isEqualToString:@"AXWindow"]) {
//            NSLog(@"--- going deeper");
            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
            [self.overlayWindowController setFrame:frame];

            NSArray<DDHOverlayElement *> *overlayElements =[self scanForUIElementsInFrame:frame];
            [tempOverlayElements addObjectsFromArray:overlayElements];
//            [tempOverlayElements addObjectsFromArray:[self overlayChildrenOfUIElement:uiElement index:index]];
        }

    }

    return [tempOverlayElements copy];
}

- (NSArray<DDHOverlayElement *> *)scanForUIElementsInFrame:(CGRect)frame {
    NSMutableArray<DDHOverlayElement *> *tempOverlayElements = [[NSMutableArray alloc] init];

    NSInteger tagInt = 0;
    CGFloat y = frame.origin.y;

    NSMutableSet<NSString *> *identifierArray = [[NSMutableSet alloc] init];
    AXUIElementRef previousElement = NULL;

    NSDate *startDate = [NSDate now];
    while (y < CGRectGetMaxY(frame)) {
        CGFloat x = frame.origin.x;
        while (x < CGRectGetMaxX(frame)) {
            NSPoint cocoaPoint = CGPointMake(x, y);
            CGPoint pointAsCGPoint = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:cocoaPoint];

            AXUIElementRef newElement = NULL;
            if (AXUIElementCopyElementAtPosition(self.simulatorRef, pointAsCGPoint.x, pointAsCGPoint.y, &newElement) == kAXErrorSuccess
                && newElement
                && (previousElement == NULL || NO == CFEqual(previousElement, newElement))) {

                NSString *role = [UIElementUtilities roleOfUIElement:newElement];
                NSRect frame = [UIElementUtilities frameOfUIElement:newElement];
//                NSString *description = [UIElementUtilities descriptionOfAXDescriptionOfUIElement:newElement];
                NSString *identifier = [NSString stringWithFormat:@"%@", [NSValue valueWithRect:frame]];
//                NSLog(@"%@ %@, role: %@, %@, %@", newElement, identifier, role, description, [NSValue valueWithRect:frame]);

                if ([role isEqualToString:@"AXButton"] ||
                    [role isEqualToString:@"AXTextField"] ||
                    [role isEqualToString:@"AXHeading"] ||
                    [role isEqualToString:@"AXStaticText"] ||
                    [role isEqualToString:@"AXRadioButton"]) {

                    if (NO == [identifierArray containsObject:identifier]) {
                        previousElement = newElement;
                        [identifierArray addObject:identifier];
                        NSString *tag = [NSString stringWithFormat:@"%ld", (long)tagInt];
//                        NSLog(@"tag: %@", tag);
                        DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:(__bridge NSValue *)newElement tag:tag];
                        [tempOverlayElements addObject:overlayElement];
                        tagInt++;
                    }
                } else {
                    previousElement = newElement;
//                    NSLog(@"%@ %@, role: %@, %@, %@", newElement, identifier, role, description, [NSValue valueWithRect:frame]);
                }

                if ([role isEqualToString:@"AXButton"] ||
                    [role isEqualToString:@"AXTextField"]) {
                    x += frame.size.width;
                } else {
                    x += 39;
                }
            } else {
                x += 39;
            }
        }
        y += 39;
    }
    NSLog(@"done in %lf s", -[startDate timeIntervalSinceNow]);

    return [tempOverlayElements copy];
}

//- (void)updateCurrentUIElement
//{
//    if (![self isInteractionWindowVisible]) {
//
//        // The current mouse position with origin at top right.
//        NSPoint cocoaPoint = [NSEvent mouseLocation];
//
//        // Only ask for the UIElement under the mouse if has moved since the last check.
//        if (!NSEqualPoints(cocoaPoint, _lastMousePoint)) {
//
//            CGPoint pointAsCGPoint = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:cocoaPoint];
//
//            AXUIElementRef newElement = NULL;
//
//            /* If the interaction window is not visible, but we still think we are interacting, change that */
//            if (_currentlyInteracting) {
//                _currentlyInteracting = ! _currentlyInteracting;
//                [_inspectorWindowController indicateUIElementIsLocked:_currentlyInteracting];
//            }
//
//            // Ask Accessibility API for UI Element under the mouse
//            // And update the display if a different UIElement
//            if (AXUIElementCopyElementAtPosition( _systemWideElement, pointAsCGPoint.x, pointAsCGPoint.y, &newElement ) == kAXErrorSuccess
//                && newElement
//                && ([self currentUIElement] == NULL || ! CFEqual( [self currentUIElement], newElement ))) {
//
//                [self setCurrentUIElement:newElement];
//                [self updateUIElementInfoWithAnimation:NO];
//
//            }
//
//            _lastMousePoint = cocoaPoint;
//        }
//    }
//}

@end
