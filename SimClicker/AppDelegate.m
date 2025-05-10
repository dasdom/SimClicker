//  Created by Dominik Hauser on 09.05.25.
//
//


#import "AppDelegate.h"
#import <AppKit/NSAccessibility.h>
#import "DDHInfoViewController.h"
#import "DDHOverlayWindowController.h"
#import "UIElementUtilities.h"

@interface AppDelegate ()
@property (nonatomic, strong) DDHOverlayWindowController *overlayWindowController;
@property (nonatomic) AXUIElementRef simulatorRef;
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
    [infoViewController updateSimulatorPickerWithNames:names];

    [window makeFirstResponder:infoViewController];
}

- (void)showOverlays {

    [self.overlayWindowController showWindow:nil];

//    NSString *role = [UIElementUtilities roleOfUIElement:self.simulatorRef];
//    NSRect frame = [UIElementUtilities frameOfUIElement:self.simulatorRef];
//    NSLog(@"sim: %@, role: %@, %@", self.simulatorRef, role, [NSValue valueWithRect:frame]);

    [self overlayChildrenOfUIElement:self.simulatorRef index:0];
}

- (void)overlayChildrenOfUIElement:(AXUIElementRef)element index:(NSInteger)index {
    NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:element];

    NSMutableArray<NSValue *> *buttons = [[NSMutableArray alloc] initWithCapacity:[children count]];
    NSMutableArray<NSValue *> *frames = [[NSMutableArray alloc] initWithCapacity:[children count]];

    for (NSValue *child in children) {
        AXUIElementRef uiElement = (__bridge AXUIElementRef)child;
        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];
        NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
        NSLog(@"%@, role: %@, %@", child, role, [NSValue valueWithRect:frame]);

        if ([role isEqualToString:@"AXButton"]) {
            [buttons addObject:child];
            [frames addObject:[NSValue valueWithRect:frame]];
        } else if ([role isEqualToString:@"AXGroup"]) {
            NSLog(@"--- going deeper");
            [self overlayChildrenOfUIElement:uiElement index:index++];
        } else if ([role isEqualToString:@"AXWindow"]) {
            NSLog(@"--- going deeper");
            [self.overlayWindowController setFrame:[UIElementUtilities frameOfUIElement:uiElement]];
            [self overlayChildrenOfUIElement:uiElement index:index++];
        }

    }
    [self.overlayWindowController addOverlaysWithFrames:frames elementIndex:index];
}

@end
