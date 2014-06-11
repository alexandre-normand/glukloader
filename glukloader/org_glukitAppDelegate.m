//
//  org_glukitAppDelegate.m
//  glukloader
//
//  Created by Alexandre Normand on 2014-03-05.
//  Copyright (c) 2014 glukit. All rights reserved.
//

#import "org_glukitAppDelegate.h"
#import <bloodSheltie/SyncManager.h>
#import "GlukloaderIcon.h"
#import "JsonEncoder.h"
#import "ModelConverter.h"
#import <gtm-oauth2/GTMOAuth2WindowController.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <NSBundle+LoginItem.h>

#define kAlreadyBeenLaunched @"AlreadyBeenLaunched"

static NSString *const TOKEN_URL = @"https://glukit.appspot.com/token";
static NSString *const AUTHORIZATION_URL = @"https://glukit.appspot.com/authorize";
static NSString *const REDIRECT_URL = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const GLUKIT_KEYCHAIN_NAME = @"glukloader";
static NSString *const CLIENT_SECRET = @"***REMOVED***";
static NSString *const CLIENT_ID = @"***REMOVED***";

static NSImage *_synchingIcon = nil;
static NSImage *_unconnectedIcon = nil;
static NSImage *_connectedIcon = nil;

#define DEBUG 1

@implementation org_glukitAppDelegate {
    SyncManager *syncManager;
    GTMOAuth2Authentication *glukitAuth;    
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
    glukitAuth = [org_glukitAppDelegate glukitAuth];    
    return self;
}

+ (GTMOAuth2Authentication *)glukitAuth {
    NSURL *tokenURL = [NSURL URLWithString:TOKEN_URL];

    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    NSString *redirectURI = REDIRECT_URL;

    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:GLUKIT_KEYCHAIN_NAME
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:CLIENT_ID
                                                         clientSecret:CLIENT_SECRET];
    return auth;
}

- (void)awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;

    BOOL didAuth = [GTMOAuth2WindowController authorizeFromKeychainForName:GLUKIT_KEYCHAIN_NAME
                                                            authentication:glukitAuth];
    if (didAuth) {
        [self.statusBar setImage:_unconnectedIcon];
        [self.statusMenu removeItem:_authenticationMenuItem];
    } else {
        [self.statusBar setImage:_unconnectedIcon];
    }

    [self initializeDefaultIfFirstRun];
    [self updateUIForAutoStart];
}

- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {

    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSString *errorStr = [error localizedDescription];

        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        NSLog(@"Error, access lost with response [%s]: %@",
                [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] UTF8String], error);
        [self stopSyncManagerIfEnabled];
    } else {
        NSLog(@"Success! We have an access token.");
        [self startSyncManagerIfAuthenticated];
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //  [auth authorizeRequest:myNSURLMutableRequest
        //       completionHandler:^(NSError *error) {
        //         if (error == nil) {
        //           // request here has been authorized
        //         }
        //       }];
        //
        // or store the authentication object into a fetcher or a Google API service
        // object like
        //
        //   [fetcher setAuthorizer:auth];

        NSLog(@"Success");
    }
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
    [self.authenticationWindow setIsVisible:TRUE];
    GTMOAuth2WindowController *windowController;
    windowController = [[GTMOAuth2WindowController alloc] initWithAuthentication:glukitAuth
                                                                authorizationURL:[NSURL URLWithString:AUTHORIZATION_URL]
                                                                keychainItemName:GLUKIT_KEYCHAIN_NAME
                                                                  resourceBundle:nil];

    [windowController signInSheetModalForWindow:[self authenticationWindow]
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];

    [self.authenticationWindow setWindowController:windowController];
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

- (void)startSyncManagerIfAuthenticated {
    BOOL didAuth = [GTMOAuth2WindowController authorizeFromKeychainForName:GLUKIT_KEYCHAIN_NAME
                                                            authentication:glukitAuth];

    if (didAuth) {
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

#pragma mark - SyncTag persistence handling methods

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
    [self transmitSyncedData:[event syncData] commitSyncTag:[event syncTag]];
}

- (void)transmitSyncedData:(SyncData *)syncData commitSyncTag:(SyncTag *)syncTag {
    NSArray *glukitReads = [ModelConverter convertGlucoseReads:[syncData glucoseReads]];
    NSArray *calibrationReads = [ModelConverter convertCalibrationReads:[syncData calibrationReads]];
    NSArray *injections = [ModelConverter convertInjections:[syncData insulinInjections]];
    NSArray *exercises = [ModelConverter convertExercises:[syncData exerciseEvents]];
    NSArray *meals = [ModelConverter convertMeals:[syncData foodEvents]];

    RACSignal *glucoseTransmit = [self signalForDataTransmitOfRecords:glukitReads endpoint:@"https://glukit.appspot.com/v1/glucosereads" recordType:@"GlucoseReads"];
    RACSignal *calibrationTransmit = [self signalForDataTransmitOfRecords:calibrationReads endpoint:@"https://glukit.appspot.com/v1/calibrations" recordType:@"CalibrationReads"];
    RACSignal *injectionTransmit = [self signalForDataTransmitOfRecords:injections endpoint:@"https://glukit.appspot.com/v1/injections" recordType:@"Injections"];
    RACSignal *exerciseTransmit = [self signalForDataTransmitOfRecords:exercises endpoint:@"https://glukit.appspot.com/v1/exercises" recordType:@"Exercises"];
    RACSignal *mealsTransmit = [self signalForDataTransmitOfRecords:meals endpoint:@"https://glukit.appspot.com/v1/meals" recordType:@"Meals"];
    RACSignal *combined = [RACSignal merge:@[glucoseTransmit, calibrationTransmit, injectionTransmit, exerciseTransmit, mealsTransmit]];

    [combined subscribeCompleted:^{
        [self saveSyncTagToDisk:syncTag];
        [self.statusBar setImage:_connectedIcon];
    }];
    [combined subscribeError:^(NSError *error) {
        // TODO : Flag error with user action?

        // This resets the manager and discards the synctag so we
        // get to retry sending the data
        [self stopSyncManagerIfEnabled];
        [self.statusBar setImage:_connectedIcon];
    }];
}

- (void)receiverPlugged:(ReceiverEvent *)event {
    NSLog(@"Received plugged in");
    [self.statusBar setImage:_connectedIcon];
}

- (void)receiverUnplugged:(ReceiverEvent *)event {
    [self.statusBar setImage:_unconnectedIcon];
}

- (RACSignal *)signalForDataTransmitOfRecords:(NSArray *)records endpoint:(NSString *)endpoint recordType:(NSString *)recordType {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        if ([records count] > 0) {
            NSArray *dictionaries = [ModelConverter JSONArrayFromModels:records];
            NSError *error;
            NSString *requestBody = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

            if (error == nil) {
                NSLog(@"Will be posting [%s] records as this\n%s", [recordType UTF8String], [requestBody UTF8String]);
            }

            NSData *payload = [requestBody dataUsingEncoding:NSUTF8StringEncoding];

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:payload];

            GTMHTTPFetcher *fetcher = [self newFetcherForRequest:request];
            [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error != nil && [error code] != 200) {
                    NSLog(@"Error accessing ressource. Payload was [%s] and error was %@",
                            [[NSString stringWithUTF8String:[data bytes]] UTF8String],
                            error.localizedDescription);
                    [subscriber sendError:error];
                } else {
                    NSLog(@"Success, got response [%s]", [[NSString stringWithUTF8String:[data bytes]] UTF8String]);
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }
            }];
        } else {
            NSLog(@"No [%s] records to transmit", [recordType UTF8String]);
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (GTMHTTPFetcher *)newFetcherForRequest:(NSMutableURLRequest *)request {
    GTMHTTPFetcher *fetcher = [[GTMHTTPFetcher alloc] initWithRequest:request];
    [fetcher setAuthorizer:glukitAuth];
    return fetcher;
}
@end
