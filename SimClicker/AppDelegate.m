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
#import "DDHSimulatorManager.h"
#import "NSArray+Extension.h"
#import "DDHRole.h"
#import "DDHCodeWindowController.h"

@interface AppDelegate () <DDHInfoWindowControllerProtocol>
//@property (nonatomic) CGSize spacing;
@property (nonatomic, strong) DDHOverlayWindowController *overlayWindowController;
@property (nonatomic, strong) DDHInfoWindowController *infoWindowController;
@property (nonatomic, strong) DDHSimulatorManager *simulatorManager;
@property (nonatomic, strong) DDHCodeWindowController *codeWindowController;
@property (nonatomic, strong) NSArray<DDHOverlayElement *> *overlayElements;
@property (nonatomic, strong) NSArray<NSString *> *possibleCharacters;
//@property (nonatomic, strong) NSArray<NSString *> *possibleTags;
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) DDHOverlayElement *selectedOverlayElement;
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

    [self checkAccessibility];

    self.possibleCharacters = @[@"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L"];
    self.simulatorManager = [[DDHSimulatorManager alloc] initWithPossibleCharacters:self.possibleCharacters];
    [self.simulatorManager.simulator addObserver:self forKeyPath:@"ownsMenuBar" options:NSKeyValueObservingOptionNew context:nil];

    [self showOverlays];

    [self.infoWindowController showWindow:nil];

    self.codeWindowController = [[DDHCodeWindowController alloc] init];
    [self.codeWindowController showWindow:nil];
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

- (void)setupInfoWindowControllerWithFrame:(NSRect)frame {
    _infoWindowController = [[DDHInfoWindowController alloc] initWithRect:frame delegate:self possibleCharacters:self.possibleCharacters];

    __weak typeof(self)weakSelf = self;

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

- (void)performActionWithName:(NSString *)actionName onElement:(AXUIElementRef)element {
    if (nil == element) {
        NSInteger index = [self.overlayElements indexOfObjectPassingTest:^BOOL(DDHOverlayElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.actionNames containsObject:actionName];
        }];
        if (index == NSNotFound) {
            return;
        }
        element = (__bridge AXUIElementRef)self.overlayElements[index].uiElementValue;
    }

    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.infoWindowController startSpinner];
    }];

    [self.overlayWindowController reset];

    pid_t pid = 0;
    if ((pid = [UIElementUtilities processIdentifierOfUIElement:element])) {
        // pull the target app forward
        NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
        if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
            // perform the action
            [UIElementUtilities performAction:actionName ofUIElement:element];
        }
    }

    element = nil;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showOverlays];
    });
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

- (void)showOverlays {

    NSDate *startDate = [NSDate now];

    [self.overlayWindowController showWindow:nil];

    NSRect frame = [self.simulatorManager simulatorWindowFrame];
    [self.overlayWindowController setFrame:frame];

    if (nil == _infoWindowController) {
        NSRect infoFrame = NSMakeRect(frame.origin.x-200, frame.origin.y+frame.size.height-200, 200, 200);

        [self setupInfoWindowControllerWithFrame:infoFrame];
    }

    self.overlayElements = [self.simulatorManager overlayChildren];

    DDHOverlayElement *toolbarElement;

    for (DDHOverlayElement *overlayElement in self.overlayElements) {
        if ([[overlayElement.role name] isEqualToString:@"AXToolbar"]) {
            toolbarElement = overlayElement;
            break;
        }
    }

    [self.overlayWindowController addOverlays:self.overlayElements toolbarElement:toolbarElement];

    if (NO == self.simulatorManager.simulator.ownsMenuBar) {
        [self.overlayWindowController hideWindow];
    }

    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.infoWindowController stopSpinner];
    }];

    CGFloat duration = -[startDate timeIntervalSinceNow];
    NSLog(@"done in %lf s", duration);
    [self.infoWindowController updateCount:[self.overlayElements count] duration:duration];
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

// MARK: - DDHInfoWindowControllerProtocol
- (void)windowController:(NSWindowController *)windowController processInput:(NSString *)input {
    if (NO == [self.simulatorManager.simulator ownsMenuBar]) {
        return;
    }

    NSLog(@"input: %@", input);

    AXUIElementRef selectedElement = (__bridge AXUIElementRef)self.selectedOverlayElement.uiElementValue;

    if (selectedElement) {
        if ([input isEqualToString:@"enter"]) {
            [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self.infoWindowController startSpinner];
            }];

            [self.overlayWindowController reset];

            pid_t pid = 0;
            if ((pid = [UIElementUtilities processIdentifierOfUIElement:selectedElement])) {
                // pull the target app forward
                NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
                if ([targetApp activateWithOptions:NSApplicationActivateAllWindows]) {
                    // perform the action
                    [UIElementUtilities performAction:@"AXPress" ofUIElement:selectedElement];
                }
            }

            [self updateCodeForElement:self.selectedOverlayElement addTap:YES];

            self.selectedOverlayElement = nil;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showOverlays];
            });
            return;
        }
    }

    if ([input isEqualToString:@"up"]) {
        [self performActionWithName:@"AXScrollUpByPage" onElement:selectedElement];
        return;
    } else if ([input isEqualToString:@"down"]) {
        [self performActionWithName:@"AXScrollDownByPage" onElement:selectedElement];
        return;
    } else if ([input isEqualToString:@"right"]) {
        [self performActionWithName:@"AXScrollRightByPage" onElement:selectedElement];
        return;
    } else if ([input isEqualToString:@"left"]) {
        [self performActionWithName:@"AXScrollLeftByPage" onElement:selectedElement];
        return;
    }

    if ([input isEqualToString:@" "]) {
        [self.overlayWindowController toggleWindowHidden];
        return;
    }

    NSUInteger index = [self.overlayElements indexOfObjectPassingTest:^BOOL(DDHOverlayElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.tag isEqualToString:input];
    }];

    [self.overlayWindowController updateWithSearchText:input];

    if (index != NSNotFound) {
        DDHOverlayElement *overlayElement = self.overlayElements[index];
        AXUIElementRef element = (__bridge AXUIElementRef)overlayElement.uiElementValue;
        self.selectedOverlayElement = overlayElement;

        NSLog(@"element: %@", [UIElementUtilities stringDescriptionOfUIElement:element]);

        [self updateCodeForElement:overlayElement addTap:NO];
    }
}

- (void)updateCodeForElement:(DDHOverlayElement *)overlayElement addTap:(BOOL)addTap {
    AXUIElementRef element = (__bridge AXUIElementRef)overlayElement.uiElementValue;
    NSString *identifier = [UIElementUtilities descriptionForUIElement:element attribute:@"AXIdentifier" beingVerbose:YES];
    NSString *description = [UIElementUtilities descriptionForUIElement:element attribute:@"AXDescription" beingVerbose:YES];
    NSString *code = [NSString stringWithFormat:@"%@[\"%@\"]%@", overlayElement.role.code, identifier ?: description, addTap ? @".tap()" : @""];
    [self.codeWindowController updateWithCode:code updateLast:addTap];
}

@end
