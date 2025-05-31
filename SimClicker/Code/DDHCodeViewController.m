//  Created by Dominik Hauser on 30.05.25.
//  
//


#import "DDHCodeViewController.h"
#import "DDHCodeView.h"
#import "DDHCodeViewDiffableDataSource.h"

@interface DDHCodeViewController ()
@property (nonatomic, strong) DDHCodeView *contentView;
@property (nonatomic, strong) DDHCodeViewDiffableDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray<NSString *> *codeLines;
@end

@implementation DDHCodeViewController

- (instancetype)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _codeLines = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    self.view = [[DDHCodeView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSTableView *tableView = self.contentView.tableView;

    self.dataSource = [[DDHCodeViewDiffableDataSource alloc] initWithTableView:tableView cellProvider:^NSView * _Nonnull(NSTableView * _Nonnull tableView, NSTableColumn * _Nonnull column, NSInteger row, NSString * _Nonnull itemId) {

        NSTableCellView *cell = [[NSTableCellView alloc] init];

        NSArray<NSString *> *components = [itemId componentsSeparatedByString:@":-)"];
        NSTextField *label = [NSTextField labelWithString:components.lastObject];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        cell.textField = label;

        [cell addSubview:label];

        [NSLayoutConstraint activateConstraints:@[
            [label.topAnchor constraintEqualToAnchor:cell.topAnchor],
            [label.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor],
            [label.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor],
            [label.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor],
        ]];

        return cell;
    }];
}

- (DDHCodeView *)contentView {
    return (DDHCodeView *)self.view;
}

- (void)updateWithCodeLines:(NSArray<NSString *> *)codeLines {
    NSDiffableDataSourceSnapshot *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    [snapshot appendSectionsWithIdentifiers:@[@"Main"]];
    [snapshot appendItemsWithIdentifiers:codeLines];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)updateWithCode:(NSString *)code updateLast:(BOOL)updateLast {
    if ([self.codeLines containsObject:code]) {
        return;
    }

    NSString *itemId = [NSString stringWithFormat:@"%@:-)%@", [NSUUID UUID].UUIDString, code];
    
    if (updateLast && self.codeLines.count > 0) {
        self.codeLines[self.codeLines.count - 1] = itemId;
    } else {
        [self.codeLines addObject:itemId];
    }

    [self updateWithCodeLines:self.codeLines];
}

@end
