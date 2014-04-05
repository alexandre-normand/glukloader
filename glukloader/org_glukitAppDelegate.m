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
#import <NXOAuth2.h>

@implementation org_glukitAppDelegate {
    SyncManager *syncManager;
}

@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;

- (id)init {
    [[NXOAuth2AccountStore sharedStore] setClientID:@"414109645872-tevu6as5d3velf5nooolfs8r1cnmgct1.apps.googleusercontent.com"
                                             secret:@"enFuzLKm2Cwnf5X_uZU48YKB"
                                              scope:[NSSet setWithObject:@"https://www.googleapis.com/auth/userinfo.profile"]
                                   authorizationURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/auth"]
                                           tokenURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/token"]
                                        redirectURL:[NSURL URLWithString:@"urn:ietf:wg:oauth:2.0:oob"]
                                     forAccountType:@"glukloader"];
    return self;
}

- (void)awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];


    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    //self.statusBar.title = @"glukloader";
    [self.statusBar setImage:[NSImage imageNamed:@"droplet"]];
    [self.statusBar setAlternateImage:[NSImage imageNamed:@"droplet.alt"]];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // Get the SyncManager
    syncManager = [[SyncManager alloc] init];

    [syncManager start:[SyncTag initialSyncTag]];
}

- (IBAction)quit:(id)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (IBAction)authenticate:(id)sender {
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"glukloader"
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
                                       [[_loginWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                   }];
}

- (void)requestTokenReceived:(NSNotification *)inNotification {
    NSLog(@"Request User Access");
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
    NSLog(@"Access Token Acquired");
}

@end
