//  Created by Dominik Hauser on 30.05.25.
//  
//


#import "DDHCodeViewDiffableDataSource.h"

@implementation DDHCodeViewDiffableDataSource
- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    NSString *itemId = [self itemIdentifierForRow:row];
    NSArray<NSString *> *components = [itemId componentsSeparatedByString:@":-)"];
    NSString *code = components.lastObject;
    NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
    [pasteboardItem setData:[code dataUsingEncoding:NSUTF8StringEncoding] forType:NSPasteboardTypeString];
    return pasteboardItem;
}
@end
