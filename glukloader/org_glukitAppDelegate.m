//
//  org_glukitAppDelegate.m
//  glukloader
//
//  Created by Alexandre Normand on 2014-03-05.
//  Copyright (c) 2014 glukit. All rights reserved.
//

#import "org_glukitAppDelegate.h"
#import <bloodSheltie/SyncManager.h>
#import <bloodSheltie/SyncTag.h>

@implementation org_glukitAppDelegate {
    SyncManager *syncManager;
}

@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    self.statusBar.title = @"glukloader";
    
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // Get the SyncManager
    syncManager = [[SyncManager alloc] init];
    
    [syncManager start:[SyncTag initialSyncTag]];
}

- (IBAction)quit:(id)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

@end
