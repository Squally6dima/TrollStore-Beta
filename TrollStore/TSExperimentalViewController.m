// TrollStore/TSExperimentalViewController.m
// Target: iOS 14.0+ — arm64 / arm64e
// Rendering: UITableViewStyleInsetGrouped + UIListContentConfiguration
// Zero deprecated API surface — eliminates -Werror=deprecated-declarations in CI

#import "TSExperimentalViewController.h"

// ─── Section index ───────────────────────────────────────────────────────────

typedef NS_ENUM(NSInteger, TSExperimentalSection) {
    TSExperimentalSectionDiagnostics = 0,
    TSExperimentalSectionSandbox,
    TSExperimentalSectionFlags,
    TSExperimentalSectionCount
};

// ─── Lightweight row descriptor ──────────────────────────────────────────────
// Typed model keeps cellForRow clean and removes stringly-typed NSDictionary
// casting that leaks -Wimplicit-retain-self warnings in ARC.

@interface _TSExperimentalRow : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *symbol;   // SF Symbol name
+ (instancetype)title:(NSString *)t
               detail:(NSString *)d
               symbol:(NSString *)s;
@end

@implementation _TSExperimentalRow
+ (instancetype)title:(NSString *)t detail:(NSString *)d symbol:(NSString *)s {
    _TSExperimentalRow *r = [_TSExperimentalRow new];
    r.title  = t;
    r.detail = d;
    r.symbol = s;
    return r;
}
@end

// ─── View Controller ─────────────────────────────────────────────────────────

@interface TSExperimentalViewController ()
// Typed 2D array: sections → rows. Built once in viewDidLoad, read-only after.
@property (nonatomic, strong) NSArray<NSArray<_TSExperimentalRow *> *> *model;
@end

@implementation TSExperimentalViewController

// UITableViewStyleInsetGrouped — inset grouped card appearance.
// Must be set here; setting it later in viewDidLoad has no effect.
- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        self.title = @"Experimental";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Large-title mode — nav controller's prefersLargeTitles is set on the
    // UINavigationController in TSRootViewController.m (not here) to avoid
    // needing a dispatch_async workaround for late-attached nav controllers.
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

    // Adaptive grouped background — resolves automatically in dark/light mode.
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // Pre-register cell class so dequeue never returns nil.
    // UIListContentConfiguration handles all rendering; UITableViewCellStyleDefault
    // is the correct base style to pair with it.
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"TSExperimentalCell"];

    // ── Data model ────────────────────────────────────────────────────────────

    self.model = @[

        // Section 0 — Diagnostics
        @[
            [_TSExperimentalRow title:@"Process Entitlements"
                               detail:@"Inspect the live entitlement blob for the current process."
                               symbol:@"doc.badge.gearshape"],
            [_TSExperimentalRow title:@"Kernel Slide Logger"
                               detail:@"Log KASLR slide and kcdata diagnostics to the system console."
                               symbol:@"terminal"],
        ],

        // Section 1 — Sandbox
        @[
            [_TSExperimentalRow title:@"Sandbox Probe"
                               detail:@"Query active container boundaries and sandbox profiles."
                               symbol:@"shield.lefthalf.filled"],
            [_TSExperimentalRow title:@"Container Path Inspector"
                               detail:@"Enumerate bundle and data container UUIDs for installed apps."
                               symbol:@"folder.badge.questionmark"],
        ],

        // Section 2 — Feature Flags
        @[
            [_TSExperimentalRow title:@"Feature Flags"
                               detail:@"Toggle experimental runtime and UI switches."
                               symbol:@"flag.2.crossed"],
            [_TSExperimentalRow title:@"URL Scheme Override"
                               detail:@"Test alternate apple-magnifier:// deep-link payloads."
                               symbol:@"link.badge.plus"],
        ],

    ];
}

// ─── UITableViewDataSource ────────────────────────────────────────────────────

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSExperimentalSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.model[section].count;
}

- (nullable NSString *)tableView:(UITableView *)tableView
         titleForHeaderInSection:(NSInteger)section {
    switch ((TSExperimentalSection)section) {
        case TSExperimentalSectionDiagnostics: return @"Diagnostics";
        case TSExperimentalSectionSandbox:     return @"Sandbox";
        case TSExperimentalSectionFlags:       return @"Feature Flags";
        default:                               return nil;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView
         titleForFooterInSection:(NSInteger)section {
    if (section == TSExperimentalSectionFlags) {
        return @"Experimental features may be unstable. Test on non-production devices.";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"TSExperimentalCell"
                                        forIndexPath:indexPath];

    _TSExperimentalRow *row = self.model[indexPath.section][indexPath.row];

    // ── UIListContentConfiguration (iOS 14+) ──────────────────────────────
    // This is the replacement for the deprecated textLabel/detailTextLabel
    // path. Using cell.textLabel here would generate
    // -Werror=deprecated-declarations on Xcode 16 / iOS 17+ SDK headers,
    // which breaks CI with FINALPACKAGE=1 (debug=0 means -O2 + -Werror).
    UIListContentConfiguration *config = [cell defaultContentConfiguration];

    // Primary text
    config.text                          = row.title;
    config.textProperties.font           = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    config.textProperties.color          = [UIColor labelColor];

    // Secondary text
    config.secondaryText                           = row.detail;
    config.secondaryTextProperties.font            = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    config.secondaryTextProperties.color           = [UIColor secondaryLabelColor];
    config.secondaryTextProperties.numberOfLines   = 2;

    // Leading SF Symbol image
    config.image                         = [UIImage systemImageNamed:row.symbol];
    config.imageProperties.tintColor     = [UIColor systemBlueColor];

    // Apply
    cell.contentConfiguration  = config;
    cell.backgroundColor       = [UIColor secondarySystemGroupedBackgroundColor];
    cell.accessoryType         = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle        = UITableViewCellSelectionStyleDefault;

    return cell;
}

// ─── UITableViewDelegate ─────────────────────────────────────────────────────

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // TODO: push per-feature detail controllers in a future stage
}

@end