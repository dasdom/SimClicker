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

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showOverlays];
        });
    };
    [infoViewController updateSimulatorPickerWithNames:names];

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

    NSLog(@">>> -----------------------------------------------------");
//    NSString *description = [UIElementUtilities descriptionForUIElement:element attribute:@"AXChildren" beingVerbose:YES];
//    NSLog(@"description: %@", description);

    NSString *role = [UIElementUtilities roleOfUIElement:element];
    NSRect frame = [UIElementUtilities frameOfUIElement:element];
    NSLog(@"%@, role: %@, %@", element, role, [NSValue valueWithRect:frame]);

//    NSArray *attributeNames = [UIElementUtilities attributeNamesOfUIElement:element];
//    NSLog(@"attributeNames: %@", attributeNames);

//    NSString *description = [UIElementUtilities stringDescriptionOfUIElement:element];
//    NSLog(@"description: %@", description);

    NSArray *lineage = [UIElementUtilities lineageOfUIElement:element];
    NSLog(@"lineage: %@", lineage);

    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:element];
//    NSLog(@"children: %@", children);

    if (children.count < 1) {
        NSLog(@"NO CHILDREN");
    }

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];
        NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
        NSLog(@"----%@, role: %@, %@", child, role, [NSValue valueWithRect:frame]);
    }

    NSLog(@"<<< -----------------------------------------------------");

    for (NSInteger i = 0; i < [children count]; i++) {
        NSValue *child = children[i];
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];
        NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
        NSLog(@"%@, role: %@, %@", child, role, [NSValue valueWithRect:frame]);

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
            [tempOverlayElements addObjectsFromArray:[self overlayChildrenOfUIElement:uiElement index:++index]];

            NSString *tag = [NSString stringWithFormat:@"%ld%ld", (long)index, (long)i];
            NSLog(@"tag: %@", tag);
            DDHOverlayElement *overlayElement = [[DDHOverlayElement alloc] initWithUIElementValue:child tag:tag];
            [tempOverlayElements addObject:overlayElement];

//            NSLog(@"<<< %ld", (long)index);
        } else if ([role isEqualToString:@"AXWindow"]) {
//            NSLog(@"--- going deeper");
            [self.overlayWindowController setFrame:[UIElementUtilities frameOfUIElement:uiElement]];
            [tempOverlayElements addObjectsFromArray:[self overlayChildrenOfUIElement:uiElement index:index]];
        }

    }

    return [tempOverlayElements copy];
}

@end
