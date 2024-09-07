//
//  ViewController.m
//  ExtensionFoundationObjCDemo
//
//  Created by Jinwoo Kim on 8/25/24.
//

#import "ViewController.h"
#import "ExtensionInterface.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import <ExtensionKit/ExtensionKit.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

@interface ViewController () <NSToolbarDelegate, EXHostViewControllerDelegate>
@property (class, readonly, nonatomic) NSToolbarItemIdentifier browserToolbarItemIdentifier;
@property (class, readonly, nonatomic) NSToolbarItemIdentifier viewToolbarItemIdentifier;
@property (class, readonly, nonatomic) NSToolbarItemIdentifier currentDateItemIdentifier;
@property (retain, readonly, nonatomic) NSToolbar *toolbar;
@property (retain, nonatomic, nullable) id availablilityObserver;
@property (assign, nonatomic) NSInteger enabledCount;
@property (assign, nonatomic) NSInteger disabledCount;
@property (assign, nonatomic) NSInteger unelectedCount;
@property (retain, nonatomic, nullable) id extensionIdentity;
@end

@implementation ViewController
@synthesize toolbar = _toolbar;

+ (NSToolbarItemIdentifier)browserToolbarItemIdentifier {
    return @"browserToolbarItemIdentifier";
}

+ (NSToolbarItemIdentifier)viewToolbarItemIdentifier {
    return @"viewToolbarItemIdentifier";
}

+ (NSToolbarItemIdentifier)currentDateItemIdentifier {
    return @"currentDateItemIdentifier";
}

- (void)dealloc {
    [_toolbar release];
    
    if (id availablilityObserver = _availablilityObserver) {
        reinterpret_cast<void (*)(Class, SEL, id)>(objc_msgSend)(objc_lookUpClass("_EXExtensionAvailablility"), sel_registerName("removeChangeObserver:"), availablilityObserver);
        [availablilityObserver release];
    }
    
    [_extensionIdentity release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    assert(self.availablilityObserver == nil);
    __weak auto weakSelf = self;
    self.availablilityObserver = reinterpret_cast<id (*)(Class, SEL, id)>(objc_msgSend)(objc_lookUpClass("_EXExtensionAvailablility"), sel_registerName("addChangeObserver:"), ^(id availablility) {
        [weakSelf didChangeExtensionAvailability:availablility];
    });
}

- (void)_viewDidMoveToWindow:(NSWindow * _Nullable)toWindow fromWindow:(NSWindow * _Nullable)fromWindow {
    objc_super superInfo = { self, [self class] };
    reinterpret_cast<void (*)(objc_super *, SEL, id, id)>(objc_msgSendSuper2)(&superInfo, _cmd, toWindow, fromWindow);
    
    if ([fromWindow.toolbar isEqual:self.toolbar]) {
        fromWindow.toolbar = nil;
    }
    
    toWindow.toolbar = self.toolbar;
    
    [self updateWindowSubtitle];
    [self updateToolbarItems];
}

- (void)didChangeExtensionAvailability:(id)availablility {
    NSInteger disabledCount = reinterpret_cast<NSInteger (*)(id, SEL)>(objc_msgSend)(availablility, sel_registerName("disabledCount"));
    NSInteger enabledCount = reinterpret_cast<NSInteger (*)(id, SEL)>(objc_msgSend)(availablility, sel_registerName("enabledCount"));
    NSInteger unelectedCount = reinterpret_cast<NSInteger (*)(id, SEL)>(objc_msgSend)(availablility, sel_registerName("unelectedCount"));
    
    NSError * _Nullable error = nil;
    
    //
    
    id extensionPointRecord = reinterpret_cast<id (*)(id, SEL, id, id *)>(objc_msgSend)([objc_lookUpClass("LSExtensionPointRecord") alloc], sel_registerName("initWithIdentifier:error:"), @"com.pookjw.ExtensionHost.Extension", &error);
    assert(error == nil);
    
    __kindof NSEnumerator *recordEnumerator = reinterpret_cast<id (*)(Class, SEL, id, NSUInteger)>(objc_msgSend)(objc_lookUpClass("LSApplicationExtensionRecord"), sel_registerName("enumeratorWithExtensionPointRecord:options:"), extensionPointRecord, 0);
    [extensionPointRecord release];
    
    id _Nullable extensionIdentity;
    if (id record = [recordEnumerator nextObject]) {
        extensionIdentity = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("_EXExtensionIdentity") alloc], sel_registerName("initWithApplicationExtensionRecord:"), record);
    } else {
        extensionIdentity = nil;
    }
    
    //
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.disabledCount = disabledCount;
        self.enabledCount = enabledCount;
        self.unelectedCount = unelectedCount;
        self.extensionIdentity = extensionIdentity;
        [self updateWindowSubtitle];
        [self updateToolbarItems];
    });
}

- (void)updateWindowSubtitle {
    self.view.window.subtitle = [NSString stringWithFormat:@"Disabled : %ld / Enabled : %ld / Unselected : %ld", self.disabledCount, self.enabledCount, self.unelectedCount];
}

- (void)updateToolbarItems {
    NSToolbar *toolbar = self.toolbar;
    
    if (id extensionIdentity = self.extensionIdentity) {
        BOOL enabled = reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(extensionIdentity, sel_registerName("enabled"));
        
        if (enabled) {
            if (![toolbar.itemIdentifiers containsObject:ViewController.viewToolbarItemIdentifier]) {
                [toolbar insertItemWithItemIdentifier:ViewController.viewToolbarItemIdentifier atIndex:0];
            }
            
            if (![toolbar.itemIdentifiers containsObject:ViewController.currentDateItemIdentifier]) {
                [toolbar insertItemWithItemIdentifier:ViewController.currentDateItemIdentifier atIndex:0];
            }
        } else {
            [toolbar removeItemWithItemIdentifier:ViewController.viewToolbarItemIdentifier];
            [toolbar removeItemWithItemIdentifier:ViewController.currentDateItemIdentifier];
        }
    } else {
        [toolbar removeItemWithItemIdentifier:ViewController.viewToolbarItemIdentifier];
        [toolbar removeItemWithItemIdentifier:ViewController.currentDateItemIdentifier];
    }
}

- (NSToolbar *)toolbar {
    if (auto toolbar = _toolbar) return toolbar;
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"ViewController"];
    
    toolbar.delegate = self;
    
    _toolbar = [toolbar retain];
    return [toolbar autorelease];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        ViewController.browserToolbarItemIdentifier,
    ];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        ViewController.browserToolbarItemIdentifier
    ];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarNavigationalItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        ViewController.browserToolbarItemIdentifier
    ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:ViewController.browserToolbarItemIdentifier]) {
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        toolbarItem.image = [NSImage imageWithSystemSymbolName:@"laser.burst" accessibilityDescription:nil];
        toolbarItem.label = @"Browser";
        toolbarItem.target = self;
        toolbarItem.action = @selector(didTriggerBrowserToolbarItem:);
        
        return [toolbarItem autorelease];
    } else if ([itemIdentifier isEqualToString:ViewController.viewToolbarItemIdentifier]) {
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        toolbarItem.image = [NSImage imageWithSystemSymbolName:@"photo" accessibilityDescription:nil];
        toolbarItem.label = @"View";
        toolbarItem.target = self;
        toolbarItem.action = @selector(didTriggerViewToolbarItem:);
        
        return [toolbarItem autorelease];
    } else if ([itemIdentifier isEqualToString:ViewController.currentDateItemIdentifier]) {
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        toolbarItem.image = [NSImage imageWithSystemSymbolName:@"calendar" accessibilityDescription:nil];
        toolbarItem.label = @"Date";
        toolbarItem.target = self;
        toolbarItem.action = @selector(didTriggerDateToolbarItem:);
        
        return [toolbarItem autorelease];
    } else {
        return nil;
    }
}

- (void)didTriggerBrowserToolbarItem:(NSToolbarItem *)sender {
    EXAppExtensionBrowserViewController *viewController = [EXAppExtensionBrowserViewController new];
    
    NSPopover *popover = [NSPopover new];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentViewController = viewController;
    [viewController release];
    popover.contentSize = NSMakeSize(400., 400.);
    
    [popover showRelativeToToolbarItem:sender];
    [popover release];
}

- (void)didTriggerViewToolbarItem:(NSToolbarItem *)sender {
    id extensionIdentity = self.extensionIdentity;
    
    if (extensionIdentity == nil) return;
    
    EXHostViewController *viewController = [EXHostViewController new];
    viewController.delegate = self;
    
    id configuration = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("_EXHostViewControllerConfiguration") alloc], sel_registerName("initWithExtensionIdentity:"), extensionIdentity);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(configuration, sel_registerName("setSceneIdentifier:"), @"scene");
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(viewController, sel_registerName("setConfiguration:"), configuration);
    [configuration release];
    
    NSPopover *popover = [NSPopover new];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentViewController = viewController;
    [viewController release];
    
    [popover showRelativeToToolbarItem:sender];
    [popover release];
}

- (void)didTriggerDateToolbarItem:(NSToolbarItem *)sender {
    id extensionIdentity = self.extensionIdentity;
    
    if (extensionIdentity == nil) return;
    
    NSError * _Nullable error = nil;
    NSXPCConnection *xpcConnection = reinterpret_cast<id (*)(id, SEL, id *)>(objc_msgSend)(extensionIdentity, sel_registerName("makeXPCConnectionWithError:"), &error);
    assert(error == nil);
    
    xpcConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ExtensionInterface)];
    [xpcConnection resume];
    
    id<ExtensionInterface> proxy = [xpcConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
    [proxy currentDateWithCompletionHandler:^(NSDate * _Nonnull date) {
        NSLog(@"%@", date);
    }];
}

- (void)hostViewControllerDidActivate:(EXHostViewController *)viewController {
    NSLog(@"%s", __func__);
}

- (void)hostViewControllerWillDeactivate:(EXHostViewController *)viewController error:(NSError *)error {
    NSLog(@"%s %@", __func__, error);
}

@end
