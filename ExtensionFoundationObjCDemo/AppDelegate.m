//
//  AppDelegate.m
//  ExtensionFoundationObjCDemo
//
//  Created by Jinwoo Kim on 8/25/24.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0., 0., 600., 400.) styleMask:NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES];
    
    window.title = NSProcessInfo.processInfo.processName;
    window.releasedWhenClosed = NO;
    window.movableByWindowBackground = YES;
    
    ViewController *contentViewController = [ViewController new];
    window.contentViewController = contentViewController;
    [contentViewController release];
    
    [window makeKeyAndOrderFront:nil];
    [window release];
}

@end
