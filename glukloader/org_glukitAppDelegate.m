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

static NSString *const TOKEN_URL = @"https://glukit.appspot.com/_ah/OAuthGetRequestToken";
static NSString *const AUTHORIZATION_URL = @"https://glukit.appspot.com/_ah/OAuthAuthorizeToken";
static NSString *const SUCCESS_URL = @"https://accounts.google.com/o/oauth2/approval";
static NSString *const SUCCESS_PREFIX = @"Success";
static NSString *const REDIRECT_URL = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const ACCOUNT_TYPE = @"glukloader";
static NSString *const CLIENT_SECRET = @"xEh2sZvNRvYnK9his1S_MlUc";
static NSString *const CLIENT_ID = @"834681386231.apps.googleusercontent.com";

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

- (void)handleOAuth2AccessResult:(NSString *)accessResult {
    //parse the page title for success or failure
    BOOL success = [accessResult rangeOfString:SUCCESS_PREFIX options:NSCaseInsensitiveSearch].location != NSNotFound;

    //if success, complete the OAuth2 flow by handling the redirect URL and obtaining a token
    if (success) {
        //authentication code and details are passed back in the form of a query string in the page title
        //parse those arguments out
        NSString *arguments = accessResult;
        if ([arguments hasPrefix:SUCCESS_PREFIX]) {
            arguments = [arguments substringFromIndex:SUCCESS_PREFIX.length + 1];
        }

        //append the arguments found in the page title to the redirect URL assigned by Google APIs
        NSString *redirectURL = [NSString stringWithFormat:@"%@?%@", REDIRECT_URL, arguments];

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


    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:@"http://localhost:8080/data"]
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

        //read the page title from the UIWebView, this is how Google APIs is returning the
        //authentication code and relation information
        //this is controlled by the redirect URL we chose to use from Google APIs
        NSString *pageTitle = frame.dataSource.pageTitle;

        [self handleOAuth2AccessResult:pageTitle];
    }
}
@end
