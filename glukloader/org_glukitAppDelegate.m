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

static NSString *const TOKEN_URL = @"https://glukit.appspot.com/token";
static NSString *const AUTHORIZATION_URL = @"https://glukit.appspot.com/authorize";
static NSString *const SUCCESS_URL = @"https://glukit.appspot.com/authorize";
static NSString *const REDIRECT_URL = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const ACCOUNT_TYPE = @"glukloader";
static NSString *const CLIENT_SECRET = @"***REMOVED***";
static NSString *const CLIENT_ID = @"***REMOVED***";

@implementation org_glukitAppDelegate {
    SyncManager *syncManager;
}

@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;

- (id)init {
    [self setupOauth2AccountStore];
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
    [self requestOAuth2Access];
}

#pragma mark - OAuth2 Logic

- (void)setupOauth2AccountStore {
    [[NXOAuth2AccountStore sharedStore] setClientID:CLIENT_ID
                                             secret:CLIENT_SECRET
                                   authorizationURL:[NSURL URLWithString:AUTHORIZATION_URL]
                                           tokenURL:[NSURL URLWithString:TOKEN_URL]
                                        redirectURL:[NSURL URLWithString:REDIRECT_URL]
                                     forAccountType:ACCOUNT_TYPE];

    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {

                                                      if (aNotification.userInfo) {
                                                          //account added, we have access
                                                          //we can now request protected data
                                                          NSLog(@"Success!! We have an access token.");
                                                          [self requestOAuth2ProtectedDetails];
                                                      } else {
                                                          //account removed, we lost access
                                                      }
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {

                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      NSLog(@"Error!! %@", error.localizedDescription);

                                                  }];
}

- (void)requestOAuth2Access {
//    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"glukloader"];
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:ACCOUNT_TYPE
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
                                       [[_loginWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                   }];
}

- (void)handleOAuth2AccessResult:(NSDictionary *)responseData{
    //parse the page title for success or failure
    NSString *code = [responseData objectForKey:CODE_KEY];
    BOOL success = code != nil;
    NSLog(@"Oauth2 success? %d", success);

    //if success, complete the OAuth2 flow by handling the redirect URL and obtaining a token
    if (success) {
        //append the arguments found in the page title to the redirect URL assigned by Glukit
        NSString *redirectURL = [NSString stringWithFormat:@"%@?state=%@&code=%@", REDIRECT_URL, [responseData objectForKey:STATE_KEY], [responseData objectForKey:CODE_KEY]];

        NSLog(@"Complete auth access by redirecting to %@", redirectURL);

        //finally, complete the flow by calling handleRedirectURL
        [[NXOAuth2AccountStore sharedStore] handleRedirectURL:[NSURL URLWithString:redirectURL]];
    } else {
        //start over
        [self requestOAuth2Access];
    }
}

- (void)requestOAuth2ProtectedDetails {
    NXOAuth2AccountStore *store = [NXOAuth2AccountStore sharedStore];
    NSArray *accounts = [store accountsWithAccountType:ACCOUNT_TYPE];


    [NXOAuth2Request performMethod:@"POST"
                        onResource:[NSURL URLWithString:@"https://glukit.appspot.com/v1/glucosereads"]
                   usingParameters:nil
                       withAccount:accounts[0]
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                   // e.g., update a progress indicator
               }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                       // Process the response
                       if (responseData) {
                           NSError *error;
                           NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                           NSLog(@"%@", userInfo);
                       }
                       if (error) {
                           NSLog(@"%@", error.localizedDescription);
                       }
                   }];
}
#pragma mark - UIWebViewDelegate methods

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame {
    NSLog(@"Finished loading frame with %@", frame.dataSource.request.URL.absoluteString);
    //if the UIWebView is showing our authorization URL, show the UIWebView control
    if ([frame.dataSource.request.URL.absoluteString rangeOfString:SUCCESS_URL options:NSCaseInsensitiveSearch].location == NSNotFound) {
        NSLog(@"Not hiding web view since looking at %@", frame.dataSource.request.URL.absoluteString);
        self.loginWebView.hidden = NO;
    } else {
        NSLog(@"Hiding web view since looking at %@", frame.dataSource.request.URL.absoluteString);
        // TODO: hide the window

        //otherwise hide the UIWebView, we've left the authorization flow
        self.loginWebView.hidden = YES;

        NSLog(@"Page is\n%s\n", [[NSString stringWithUTF8String:[frame.dataSource.data bytes]] UTF8String]);
        // Read the json response
        NSError *error = nil;
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:frame.dataSource.data options:kNilOptions error:&error];

        if (error) {
            NSLog(@"Could not read authorization response: [%s]", [[NSString stringWithUTF8String:[frame.dataSource.data bytes]] UTF8String]);
            return;
        }

        [self handleOAuth2AccessResult:responseData];
    }
}
@end
