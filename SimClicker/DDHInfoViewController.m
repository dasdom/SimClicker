//  Created by Dominik Hauser on 09.05.25.
//  
//


#import "DDHInfoViewController.h"

@interface DDHInfoViewController ()
@property (weak) IBOutlet NSPopUpButton *simulatorButton;
@end

@implementation DDHInfoViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}

- (void)updateSimulatorPickerWithNames:(NSArray<NSString *> *)names {
  [self.simulatorButton removeAllItems];

  for (NSString *name in names) {
    [self.simulatorButton addItemWithTitle:name];
  }
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (void)keyDown:(NSEvent *)event {
  NSLog(@"event %@", event);
}

- (IBAction)activate:(NSButton *)sender {
    
}

@end
