//
//  org_glukitAppDelegate.m
//  glukloader
//
//  Created by Alexandre Normand on 2014-03-05.
//  Copyright (c) 2014 glukit. All rights reserved.
//

#import "org_glukitAppDelegate.h"
#import <bloodSheltie/SyncManager.h>
#import <NXOAuth2Client/NXOAuth2.h>
#import <NXOAuth2Client/NXOAuth2Request.h>
#import "GlukloaderIcon.h"
#import "JsonEncoder.h"
#import "ModelConverter.h"
#import <NXOAuth2Client/NXOAuth2AccountStore.h>
#import <Mantle/MTLJSONAdapter.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <NSBundle+LoginItem.h>

#define kAlreadyBeenLaunched @"AlreadyBeenLaunched"

static NSString *const TOKEN_URL = @"https://glukit.appspot.com/token";
static NSString *const AUTHORIZATION_URL = @"https://glukit.appspot.com/authorize";
static NSString *const SUCCESS_URL = @"https://glukit.appspot.com/authorize";
static NSString *const REDIRECT_URL = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const ACCOUNT_TYPE = @"glukloader";
static NSString *const CLIENT_SECRET = @"xEh2sZvNRvYnK9his1S_sdd2MlUc";
static NSString *const CLIENT_ID = @"834681386231.mygluk.it";

static NSImage *_synchingIcon = nil;
static NSImage *_unconnectedIcon = nil;
static NSImage *_connectedIcon = nil;

@implementation org_glukitAppDelegate {
    SyncManager *syncManager;
}

@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;
@synthesize autoStartMenuItem = _autoStartMenuItem;

+ (void)initialize {
    _synchingIcon = [GlukloaderIcon imageOfIconWithSize:16.f isConnected:true isSyncInProgress:true];
    _unconnectedIcon = [GlukloaderIcon imageOfIconWithSize:16.f isConnected:false isSyncInProgress:false];
    _connectedIcon = [GlukloaderIcon imageOfIconWithSize:16.f isConnected:true isSyncInProgress:false];
}

- (id)init {
    [self setupOauth2AccountStore];
    return self;
}

- (void)awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    NXOAuth2AccountStore *store = [NXOAuth2AccountStore sharedStore];
    NSArray *accounts = [store accountsWithAccountType:ACCOUNT_TYPE];

    if ([accounts count] > 0) {
        [self.statusBar setImage:_unconnectedIcon];
        [self.statusMenu removeItem:_authenticationMenuItem];
    } else {
        [self.statusBar setImage:_unconnectedIcon];
        [self.authenticationWindow setIsVisible:TRUE];
    }

    [self initializeDefaultIfFirstRun];
    [self updateUIForAutoStart];
}

- (void)initializeDefaultIfFirstRun {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kAlreadyBeenLaunched]) {
        // Setting userDefaults for next time
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kAlreadyBeenLaunched];

        // Set auto-start to ON by default
        [[NSBundle mainBundle] addToLoginItems];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self startSyncManagerIfAuthenticated];
}

- (IBAction)quit:(id)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (IBAction)authenticate:(id)sender {
    [self requestOAuth2Access];
}

- (IBAction)toggleAutoStart:(id)sender {
    if (self.autoStartMenuItem.state == NSOnState) {
        // Disable autostart
        [[NSBundle mainBundle] removeFromLoginItems];
    } else {
        // Enable autostart
        [[NSBundle mainBundle] addToLoginItems];
    }

    [self updateUIForAutoStart];
}

- (void)updateUIForAutoStart {
    BOOL isEnabled = [[NSBundle mainBundle] isLoginItem];
    NSInteger state = NSOffState;
    if (isEnabled) {
        state = NSOnState;
    }
    [self.autoStartMenuItem setState:state];
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
            NSLog(@"Success! We have an access token.");
            [self startSyncManagerIfAuthenticated];
        } else {
            //account removed, we lost access
            NSLog(@"Account removed");
            [self stopSyncManagerIfEnabled];
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

- (void)startSyncManagerIfAuthenticated {

    NXOAuth2AccountStore *store = [NXOAuth2AccountStore sharedStore];
    NSArray *accounts = [store accountsWithAccountType:ACCOUNT_TYPE];

    if ([accounts count] > 0) {
        NSLog(@"Authentication found, starting sync manager...");
        // Get the SyncManager
        syncManager = [[SyncManager alloc] init];
        [syncManager registerEventListener:self];
        SyncTag *tag = [self loadDataFromDisk];
        if (tag == nil) {
            tag = [SyncTag initialSyncTag];
        }

        [syncManager start:tag];
    }
}

- (void)stopSyncManagerIfEnabled {

    if (syncManager != nil) {
        NSLog(@"Authentication found, starting sync manager...");
        // Get the SyncManager
        [syncManager stop];
        syncManager = nil;
    }
}

- (void)requestOAuth2Access {
//    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"glukloader"];
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:ACCOUNT_TYPE
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        [[_loginWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:preparedURL]];
    }];
}

- (void)handleOAuth2AccessResult:(NSDictionary *)responseData {
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

- (NSString *)pathForDataFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *folder = @"~/Library/Application Support/Glukloader/";
    folder = [folder stringByExpandingTildeInPath];

    if (![fileManager fileExistsAtPath:folder]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error creating directory to hold configuration: %@", error);
        };

    }

    NSString *fileName = @"Glukloader.state";
    return [folder stringByAppendingPathComponent:fileName];
}

- (void)saveSyncTagToDisk:(SyncTag *)tag {
    NSString *path = [self pathForDataFile];

    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];

    [rootObject setValue:tag forKey:SYNC_TAG_KEY];
    [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
    NSLog(@"Saved tag [%@] to disk", tag);
}

- (SyncTag *)loadDataFromDisk {
    NSString *path = [self pathForDataFile];
    NSDictionary *rootObject;

    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    SyncTag *tag = [rootObject valueForKey:SYNC_TAG_KEY];
    NSLog(@"Loaded tag [%@] from disk", tag);
    return tag;
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

- (void)syncStarted:(SyncEvent *)event {
    NSLog(@"Sync started at %@", [NSDate date]);
    [self.statusBar setImage:_synchingIcon];
}

- (void)errorReadingReceiver:(SyncEvent *)event {
    NSLog(@"Error received");
    // TODO Change icon to warning about failure?
}

- (void)syncProgress:(SyncProgressEvent *)event {
    NSLog(@"Sync progressing");
    // TODO: Animate icon
}

- (void)syncComplete:(SyncCompletionEvent *)event {
    NSLog(@"Sync complete at %@ with %lu reads, %lu calibrations, %lu injections, %lu exercises, %lu meals",
            [NSDate date],
            event.syncData.glucoseReads.count,
            event.syncData.calibrationReads.count,
            event.syncData.insulinInjections.count,
            event.syncData.exerciseEvents.count,
            event.syncData.foodEvents.count);
    BOOL status = [self transmitSyncedData:[event syncData]];

    if (status) {
        [self saveSyncTagToDisk:event.syncTag];
    } else {
        // TODO : Flag error with user action?

        // This resets the manager and discards the synctag so we
        // get to retry sending the data
        [self stopSyncManagerIfEnabled];
        //[self startSyncManagerIfAuthenticated];
    }

    [self.statusBar setImage:_connectedIcon];
}

- (BOOL)transmitSyncedData:(SyncData *)syncData {
    NSArray *glukitReads = [ModelConverter convertGlucoseReads:[syncData glucoseReads]];
    NSArray *calibrationReads = [ModelConverter convertCalibrationReads:[syncData calibrationReads]];
    NSArray *injections = [ModelConverter convertInjections:[syncData insulinInjections]];
    NSArray *exercises = [ModelConverter convertExercises:[syncData exerciseEvents]];
    NSArray *meals = [ModelConverter convertMeals:[syncData foodEvents]];

    [self transmitData:glukitReads endpoint:@"https://glukit.appspot.com/v1/glucosereads" recordType:@"GlucoseReads"];
    [self transmitData:calibrationReads endpoint:@"https://glukit.appspot.com/v1/calibrations" recordType:@"CalibrationReads"];
    [self transmitData:injections endpoint:@"https://glukit.appspot.com/v1/injections" recordType:@"Injections"];
    [self transmitData:exercises endpoint:@"https://glukit.appspot.com/v1/exercises" recordType:@"Exercises"];
    [self transmitData:meals endpoint:@"https://glukit.appspot.com/v1/meals" recordType:@"Meals"];
    return YES;
}

- (void)transmitData:(NSArray *)records endpoint:(NSString *)endpoint recordType:(NSString *)recordType {
    if ([records count] > 0) {
        NSArray *dictionaries = [ModelConverter JSONArrayFromModels:records];
        NSError *error;
        NSString *requestBody = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

        if (error == nil) {
            NSLog(@"Will be posting [%s] records as this\n%s", [recordType UTF8String], [requestBody UTF8String]);
        }

        NSData *payload = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
        NXOAuth2AccountStore *store = [NXOAuth2AccountStore sharedStore];
        NSArray *accounts = [store accountsWithAccountType:ACCOUNT_TYPE];

        NXOAuth2Request *request = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:endpoint]
                                                                      method:@"POST"
                                                                  parameters:nil];
        request.account = accounts[0];
        NSMutableURLRequest *urlRequest = [[request signedURLRequest] mutableCopy];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:payload];

        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error1) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            // Process the response
            if ([httpResponse statusCode] == [@200 integerValue]) {
                NSLog(@"Success, got response [%s]", [[NSString stringWithUTF8String:[data bytes]] UTF8String]);
            }

            if (error1 != nil) {
                NSLog(@"Error accessing ressource, clearing account [%@]. Payload was [%s] and error was %@", accounts[0],
                        [[NSString stringWithUTF8String:[data bytes]] UTF8String],
                        error1.localizedDescription);
                [store removeAccount:accounts[0]];
            }
        }];
    } else {
        NSLog(@"No [%s] records to transmit", [recordType UTF8String]);
    }
}

- (void)receiverPlugged:(ReceiverEvent *)event {
    NSLog(@"Received plugged in");
    [self.statusBar setImage:_connectedIcon];
}

- (void)receiverUnplugged:(ReceiverEvent *)event {
    [self.statusBar setImage:_unconnectedIcon];
}

@end
