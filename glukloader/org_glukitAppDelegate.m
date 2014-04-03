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
#import <MPOAuth/MPOAuth.h>

@implementation org_glukitAppDelegate {
    SyncManager *syncManager;
    MPOAuthAPI *_oauthAPI;
}

@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;

- (id)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
    }
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
    if (!_oauthAPI) {
        NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:@"414109645872-tevu6as5d3velf5nooolfs8r1cnmgct1.apps.googleusercontent.com", kMPOAuthCredentialConsumerKey,
                                                                               @"enFuzLKm2Cwnf5X_uZU48YKB", kMPOAuthCredentialConsumerSecret,
                                                                               nil];
        _oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
                                          authenticationURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/auth"]
                                                 andBaseURL:[NSURL URLWithString:@"https://www.googleapis.com/auth/userinfo.profile"]];
    } else {
        [_oauthAPI authenticate];
    }

//    [_oauthAPI performMethod:@"GET" withTarget:self andAction:@selector(performedMethodLoadForURL:withResponseBody:)];
}

- (void)requestTokenReceived:(NSNotification *)inNotification {
    NSLog(@"Request User Access");
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
    NSLog(@"Access Token Acquired");
}

@end
