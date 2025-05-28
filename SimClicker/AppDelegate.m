//  Created by Dominik Hauser on 09.05.25.
//
//


#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#import <AppKit/NSAccessibility.h>
#import "DDHInfoViewController.h"
#import "DDHOverlayWindowController.h"
#import "UIElementUtilities.h"
#import "DDHOverlayElement.h"
#import "DDHInfoWindowController.h"
#import "NSArray+Extension.h"

@interface AppDelegate ()
@property (nonatomic) CGSize spacing;
@property (nonatomic, strong) DDHOverlayWindowController *overlayWindowController;
@property (nonatomic, strong) DDHInfoWindowController *infoWindowController;
//@property (nonatomic, strong) DDHInfoViewController *infoViewController;
@property (nonatomic, strong) NSRunningApplication *simulator;
@property (nonatomic) AXUIElementRef simulatorRef;
@property (nonatomic, strong) NSArray<DDHOverlayElement *> *overlayElements;
@property (nonatomic, strong) NSArray<NSString *> *possibleCharacters;
@property (nonatomic, strong) NSArray<NSString *> *possibleTags;
@property (nonatomic) BOOL isActive;
@property (nonatomic) AXUIElementRef selectedElement;
@end

@implementation AppDelegate

EventHotKeyRef    gMyHotKeyRef;

OSStatus LockUIElementHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData) {
    AppDelegate *appController = (__bridge AppDelegate *)userData;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:appController selector:@selector(toggleActivation:) userInfo:nil repeats:NO];
    return noErr;
}

static OSStatus RegisterLockUIElementHotKey(void *userInfo) {

    EventTypeSpec eventType = { kEventClassKeyboard, kEventHotKeyReleased };
    InstallApplicationEventHandler(NewEventHandlerUPP(LockUIElementHotKeyHandler), 1, &eventType,(void *)userInfo, NULL);

    EventHotKeyID hotKeyID = { 'lUIk', 1 }; // we make up the ID
    return RegisterEventHotKey(kVK_Space, cmdKey | shiftKey, hotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef); // Cmd-F7 will be the key to hit

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    RegisterLockUIElementHotKey((__bridge void *)self);

    self.isActive = YES;
    self.spacing = CGSizeMake(15, 15);
    self.possibleTags = [self generatePossibleTags];

    [self checkAccessibility];

    [self findSimulators];

    [self showOverlays];

    [self.infoWindowController showWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (NSArray<NSString *> *)generatePossibleTags {
    NSArray<NSString *> *characters = @[@"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L"];
    NSMutableArray<NSString *> *possibleTags = [[NSMutableArray alloc] init];
    for (NSString *c1 in characters) {
        for (NSString *c2 in characters) {
            NSString *tag = [NSString stringWithFormat:@"%@%@", c1, c2];
            [possibleTags addObject:tag];
        }
    }
    self.possibleCharacters = characters;
    return [possibleTags copy];
}

// MARK: -
- (DDHOverlayWindowController *)overlayWindowController {
    if (nil == _overlayWindowController) {
        _overlayWindowController = [[DDHOverlayWindowController alloc] init];
    }
    return _overlayWindowController;
}

- (void)setupInfoWindowControllerWithFrame:(NSRect)frame {
    _infoWindowController = [[DDHInfoWindowController alloc] initWithRect:frame possibleCharacters:self.possibleCharacters];

    __weak typeof(self)weakSelf = self;
    _infoWindowController.inputHandler = ^(NSString * _Nonnull input) {

        if (NO == [weakSelf.simulator ownsMenuBar]) {
            return;
        }

        NSLog(@"input: %@", input);

        if (weakSelf.selectedElement) {
            if ([input isEqualToString:@"enter"]) {
                [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [weakSelf.infoWindowController startSpinner];
                }];

                [weakSelf.overlayWindowController reset];

                pid_t pid = 0;
                if ((pid = [UIElementUtilities processIdentifierOfUIElement:weakSelf.selectedElement])) {
                    // pull the target app forward
                    NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
                    if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
                        // perform the action
                        [UIElementUtilities performAction:@"AXPress" ofUIElement:weakSelf.selectedElement];
                    }
                }

                weakSelf.selectedElement = nil;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf showOverlays];
                });
                return;
            } else if ([input isEqualToString:@"up"]) {
                [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [weakSelf.infoWindowController startSpinner];
                }];

                [weakSelf.overlayWindowController reset];

                pid_t pid = 0;
                if ((pid = [UIElementUtilities processIdentifierOfUIElement:weakSelf.selectedElement])) {
                    // pull the target app forward
                    NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
                    if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
                        // perform the action
                        [UIElementUtilities performAction:@"AXScrollUpByPage" ofUIElement:weakSelf.selectedElement];
                    }
                }

                weakSelf.selectedElement = nil;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf showOverlays];
                });
                return;
            } else if ([input isEqualToString:@"down"]) {
                [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [weakSelf.infoWindowController startSpinner];
                }];

                [weakSelf.overlayWindowController reset];

                pid_t pid = 0;
                if ((pid = [UIElementUtilities processIdentifierOfUIElement:weakSelf.selectedElement])) {
                    // pull the target app forward
                    NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
                    if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
                        // perform the action
                        [UIElementUtilities performAction:@"AXScrollDownByPage" ofUIElement:weakSelf.selectedElement];
                    }
                }

                weakSelf.selectedElement = nil;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf showOverlays];
                });
                return;
            }
        }

        if ([input isEqualToString:@" "]) {
            [weakSelf.overlayWindowController toggleWindowHidden];
            return;
        }

        NSUInteger index = [weakSelf.overlayElements indexOfObjectPassingTest:^BOOL(DDHOverlayElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.tag isEqualToString:input];
        }];

        [weakSelf.overlayWindowController updateWithSearchText:input];

        if (index != NSNotFound) {
            AXUIElementRef element = (__bridge AXUIElementRef)weakSelf.overlayElements[index].uiElementValue;
            weakSelf.selectedElement = element;
        }


//        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
//            [weakSelf.infoWindowController startSpinner];
//        }];
//
//        [weakSelf.overlayWindowController reset];
//
//        pid_t pid = 0;
//        if ((pid = [UIElementUtilities processIdentifierOfUIElement:element])) {
//            // pull the target app forward
//            NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
//            if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
//                // perform the action
//                [UIElementUtilities performAction:@"AXPress" ofUIElement:element];
//            }
//        }
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf showOverlays];
//        });
    };

//    _infoWindowController.gridToggleHandler = ^(BOOL showGrid) {
//        if (showGrid) {
//            [weakSelf.overlayWindowController showGrid];
//        } else {
//            [weakSelf.overlayWindowController hideGrid];
//        }
//    };

    _infoWindowController.activateToggleHandler = ^(BOOL active) {
        weakSelf.isActive = active;

        [weakSelf.overlayWindowController activate:active];
        [weakSelf.infoWindowController activate:active];
    };

    _infoWindowController.rescanHandler = ^{
        [weakSelf.infoWindowController startSpinner];

        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [weakSelf showOverlays];
        }];
    };
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
    self.simulator = simulator;
    NSLog(@"applicationRef: %@", self.simulatorRef);

    [simulator addObserver:self forKeyPath:@"ownsMenuBar" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)showOverlays {

    NSDate *startDate = [NSDate now];

    [self.overlayWindowController showWindow:nil];

    self.overlayElements = [self overlayChildrenOfUIElement:self.simulatorRef index:0];

    DDHOverlayElement *toolbarElement;
    for (NSInteger i = 0; i < [self.overlayElements count]; i++) {
        DDHOverlayElement *overlayElement = self.overlayElements[i];
        overlayElement.tag = self.possibleTags[i];

        NSLog(@"%@, %@, %@", overlayElement.tag, overlayElement.role, [NSValue valueWithRect:overlayElement.frame]);

        if ([overlayElement.role isEqualToString:@"AXToolbar"]) {
            toolbarElement = overlayElement;
        }
    }

    [self.overlayWindowController addOverlays:self.overlayElements toolbarElement:toolbarElement];

    if (NO == self.simulator.ownsMenuBar) {
        [self.overlayWindowController hideWindow];
    }

    //    NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
    //    [currentApplication activateWithOptions:NSApplicationActivateAllWindows];

    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.infoWindowController stopSpinner];
    }];

    CGFloat duration = -[startDate timeIntervalSinceNow];
    NSLog(@"done in %lf s", duration);
    [self.infoWindowController updateCount:[self.overlayElements count] duration:duration];
}

- (NSArray<DDHOverlayElement *> *)overlayChildrenOfUIElement:(AXUIElementRef)element index:(NSInteger)index {
    NSMutableArray<DDHOverlayElement *> *tempOverlayElements = [[NSMutableArray alloc] init];

    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:element];

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];
//        NSString *description = [UIElementUtilities descriptionOfAXDescriptionOfUIElement:uiElement];
//        NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
//        NSLog(@"%@ %@, role: %@, %@", child, role, description, [NSValue valueWithRect:frame]);

        if ([role isEqualToString:@"AXGroup"]) {
            NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:uiElement index:index + 1];
            [tempOverlayElements addObjectsFromArray:overlayElements];

            if (overlayElements.count < 1) {
                NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
                NSArray<DDHOverlayElement *> *overlayElements = [self scanForUIElementsInFrame:frame];
                [tempOverlayElements addObjectsFromArray:overlayElements];
            }
        } else if ([role isEqualToString:@"AXToolbar"] ||
                   [role isEqualToString:@"AXMenuBar"]) {
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
            DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:child frame:frame role:role actionNames:actionNames tag:tag];
            [tempOverlayElements addObject:overlayElement];
        } else if ([role isEqualToString:@"AXWindow"]) {
            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
//            NSLog(@"simulator frame: %@", [NSValue valueWithRect:frame]);

            [self.overlayWindowController setFrame:frame spacing:self.spacing];

            if (nil == _infoWindowController) {
                NSRect infoFrame = NSMakeRect(frame.origin.x-200, frame.origin.y+frame.size.height-200, 200, 200);

                [self setupInfoWindowControllerWithFrame:infoFrame];
            }

            NSArray<DDHOverlayElement *> *overlayElements = [self overlayChildrenOfUIElement:uiElement index:index + 1];
            [tempOverlayElements addObjectsFromArray:overlayElements];

        } else {
            NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];

            NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:uiElement];
            NSString *tag = [NSString stringWithFormat:@"%ld%ld", (long)index, (long)i];
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
            
            [self.overlayWindowController setFrame:frame spacing:self.spacing];

            if (nil == _infoWindowController) {
                NSRect infoFrame = NSMakeRect(frame.origin.x-200, frame.origin.y+frame.size.height-200, 200, 200);

                [self setupInfoWindowControllerWithFrame:infoFrame];
            }

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

                NSString *role = [UIElementUtilities roleOfUIElement:newElement];
                NSRect frame = [UIElementUtilities frameOfUIElement:newElement];

//                NSString *description = [UIElementUtilities descriptionOfAXDescriptionOfUIElement:newElement];
                NSString *identifier = [NSString stringWithFormat:@"%@", [NSValue valueWithRect:frame]];
//                NSLog(@"%@ %@, role: %@, %@", newElement, role, description, [NSValue valueWithRect:frame]);

                if (NO == [role isEqualToString:@"AXGroup"]) {

                    if (NO == [identifierArray containsObject:identifier]) {
                        previousElement = newElement;
                        [identifierArray addObject:identifier];
                        NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:newElement];
                        NSString *tag = self.possibleTags[tagInt]; //[NSString stringWithFormat:@"%ld", (long)tagInt];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    NSNumber *ownsMenubarNumber = (NSNumber *)change[NSKeyValueChangeNewKey];
    BOOL simulatorOwnsMenuBar = [ownsMenubarNumber boolValue];

    if (simulatorOwnsMenuBar) {
        [self.overlayWindowController showWindow];
    } else {
        [self.overlayWindowController hideWindow];
    }
}

// MARK: - Actions
- (void)toggleActivation:(id)sender {
    self.isActive = !self.isActive;

    [self.overlayWindowController activate:self.isActive];
    [self.infoWindowController activate:self.isActive];
}

@end
