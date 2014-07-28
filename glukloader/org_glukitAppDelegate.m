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
    NSString *lastRefreshToken;
    NSDateFormatter *filenameDateFormatter;
    GTMOAuth2WindowController *_windowController;
    BOOL receiverPluggedIn;
    BOOL syncInProgress;
}

@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;
@synthesize autoStartMenuItem = _autoStartMenuItem;
@synthesize progressIndicator = _progressIndicator;
@synthesize progressWindow = _progressWindow;

+ (void)initialize {
    _synchingIcon = [GlukloaderIcon imageOfIconWithIsConnected:true isSyncInProgress:true];
    _unconnectedIcon = [GlukloaderIcon imageOfIconWithIsConnected:false isSyncInProgress:false];
    _connectedIcon = [GlukloaderIcon imageOfIconWithIsConnected:true isSyncInProgress:false];
}

- (id)init {
    if ((self = [super init])) {
        glukitAuth = [org_glukitAppDelegate createAuth];
        _windowController = [[GTMOAuth2WindowController alloc] initWithAuthentication:glukitAuth
                                                                     authorizationURL:[NSURL URLWithString:AUTHORIZATION_URL]
                                                                     keychainItemName:GLUKIT_KEYCHAIN_NAME
                                                                       resourceBundle:nil];

        NSLog(@"Loaded Oauth From Keychain [%@]", glukitAuth);
        lastRefreshToken = [glukitAuth refreshToken];
        filenameDateFormatter = [[NSDateFormatter alloc] init];
        receiverPluggedIn = NO;
        syncInProgress = NO;
        [filenameDateFormatter setDateFormat:@"dd-MM-yyyy'T'hh:mm:ssZ"];
    }
    return self;
}

+ (GTMOAuth2Authentication *)createAuth {

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
        [self hideAuthentication];
    } else {
        [self startOauthFlow];
    }

    [self updateGlukloaderIcon];
    [self initializeDefaultIfFirstRun];
    [self updateUIForAutoStart];
}

- (void)hideAuthentication {
    [self.authenticationWindow setIsVisible:FALSE];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(authenticate:)) {
        return !(glukitAuth != nil && [glukitAuth canAuthorize]);
    }
    else if ([menuItem action] == @selector(resendDataToGlukit:)) {
        return (glukitAuth != nil && [glukitAuth canAuthorize]);
    }
    else {
        return YES;
    }
}

- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {

    if (error != nil) {
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        NSLog(@"Error, access lost with response [%s]: %@",
                [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] UTF8String], error);
        [self stopSyncManagerIfEnabled];
    } else {
        NSLog(@"Success! We have an access token: [%@]", glukitAuth);

        [self hideAuthentication];
        [self startSyncManagerIfAuthenticated];
    }
}

- (void)updateGlukloaderIcon {
    if (glukitAuth == nil || ![glukitAuth canAuthorize]) {
        [self.statusBar setImage:_unconnectedIcon];
    } else if (receiverPluggedIn) {
        if (syncInProgress) {
            [self.statusBar setImage:_synchingIcon];
        } else {
            [self.statusBar setImage:_connectedIcon];
        }
    } else {
        [self.statusBar setImage:_unconnectedIcon];
    }
}

- (BOOL)webViewIsResizable:(WebView *)sender {
    return NO;
}

- (void)updateRefreshTokenInKeychainIfRequired {
    if (glukitAuth.refreshToken != lastRefreshToken) {
        NSLog(@"Updating keychain with refresh token [%s]", [[glukitAuth refreshToken] UTF8String]);
        [GTMOAuth2WindowController saveAuthToKeychainForName:GLUKIT_KEYCHAIN_NAME authentication:glukitAuth];
        lastRefreshToken = [glukitAuth refreshToken];
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
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self stopSyncManagerIfEnabled];
}

- (IBAction)authenticate:(id)sender {
    [self startOauthFlow];

}

- (IBAction)resendDataToGlukit:(id)sender {
    NSError *error;
    NSString *glukitRoot = [self glukitRoot];

    NSArray *glucoseReadSignals = [self prepareTransmissionTasks:glukitRoot recordType:GLUCOSE_READ_TYPE modelClass:[GlukitGlucoseRead class] endpoint:GLUCOSE_READ_ENDPOINT error:&error];
    NSArray *exerciseSignals = [self prepareTransmissionTasks:glukitRoot recordType:EXERCISE_TYPE modelClass:[GlukitExercise class] endpoint:EXERCISES_ENDPOINT error:&error];
    NSArray *injectionSignals = [self prepareTransmissionTasks:glukitRoot recordType:INJECTION_TYPE modelClass:[GlukitInjection class] endpoint:INJECTIONS_ENDPOINT error:&error];
    NSArray *calibrationSignals = [self prepareTransmissionTasks:glukitRoot recordType:CALIBRATION_READ_TYPE modelClass:[GlukitCalibrationRead class] endpoint:CALIBRATIONS_ENDPOINT error:&error];
    NSArray *mealSignals = [self prepareTransmissionTasks:glukitRoot recordType:MEALS_TYPE modelClass:[GlukitMeal class] endpoint:MEALS_ENDPOINT error:&error];
    NSMutableArray *allTransmits = [[NSMutableArray alloc] init];
    [allTransmits addObjectsFromArray:glucoseReadSignals];
    [allTransmits addObjectsFromArray:exerciseSignals];
    [allTransmits addObjectsFromArray:injectionSignals];
    [allTransmits addObjectsFromArray:calibrationSignals];
    [allTransmits addObjectsFromArray:mealSignals];

    int numberOfSteps = [allTransmits count];
    [self initializeProgressWindow:numberOfSteps];

    RACSignal *combined = [RACSignal concat:allTransmits];

    [combined subscribeNext:^(id x) {
        NSLog(@"Increment progress bar");
        [_progressIndicator incrementBy:1.];
    }
                      error:^(NSError *err) {
        // TODO : Flag error with user action?
        // This resets the manager and discards the synctag so we
        // get to retry sending the data
        [self stopSyncManagerIfEnabled];
        [self updateGlukloaderIcon];
    }
                  completed:^{
        NSLog(@"Completed resend of all data.");
        [self updateGlukloaderIcon];
        [self hideProgressWindow];
    }];
}

- (void)hideProgressWindow {
    [_progressWindow setIsVisible:NO];
    [_progressIndicator setMaxValue:0];
}

- (void)initializeProgressWindow:(int)numberOfSteps {
    [_progressIndicator setMaxValue:numberOfSteps];
    [_progressIndicator setDoubleValue:0.];
    [_progressIndicator setUsesThreadedAnimation:YES];
    [_progressIndicator startAnimation:self];
    [_progressIndicator setIndeterminate:NO];
    [_progressWindow setIsVisible:YES];
    [_progressWindow setLevel:NSFloatingWindowLevel];
    [_progressWindow makeKeyAndOrderFront:self];
}

- (NSArray *)prepareTransmissionTasks:(NSString *)glukitRoot recordType:(NSString *const)recordType modelClass:(Class)modelClass endpoint:(NSString *const)endpoint error:(NSError **)error {
    NSError *err;
    NSMutableArray *transmitTasks = [[NSMutableArray alloc] init];
    NSArray *files = [self getFilesOfType:glukitRoot recordType:recordType error:&err];

    if (err != nil) {
        *error = err;
        return nil;
    }

    NSLog(@"Found files for %@: %@", recordType, files);

    for (id filename in files) {
        NSLog(@"Prepared transmission of [%@] records from file [%@].", recordType, filename);
        [transmitTasks addObject:[self signalForDataTransmitOfRecordsFromFile:filename
                                                                     endpoint:endpoint
                                                                   recordType:recordType
                                                                   modelClass:modelClass]];
    }

    return transmitTasks;
}

- (NSArray *)getFilesOfType:(NSString *)glukitRoot recordType:(NSString *const)recordType error:(NSError **)error {
    NSError *err;
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:glukitRoot error:&err];
    if (err != nil) {
        NSLog(@"Error listing files in glukit root [%@]: %@", glukitRoot, (*error));
        *error = err;
        return nil;
    } else {
        NSPredicate *recordFileFormat = [NSPredicate predicateWithFormat:@"(self ENDSWITH '.json') AND (self BEGINSWITH $type)"];
        NSArray *recordFiles =
                [dirFiles filteredArrayUsingPredicate:[recordFileFormat predicateWithSubstitutionVariables:@{@"type" : recordType}]];
        NSArray *sortedArray = [NSArray arrayWithArray:[recordFiles sortedArrayUsingComparator:^(NSString *filenameA, NSString *filenameB) {
            NSString *dateAString = [self dateStringFromFilename:filenameA];
            NSDate *dateA = [filenameDateFormatter dateFromString:dateAString];
            NSString *dateBString = [self dateStringFromFilename:filenameB];
            NSDate *dateB = [filenameDateFormatter dateFromString:dateBString];
            return [dateA compare:dateB];
        }]];

        return sortedArray;
    }
}

- (NSString *)dateStringFromFilename:(NSString *)filename {
    NSRange startOfDate = [filename rangeOfString:@"-"];
    NSRange endOfDate = [filename rangeOfString:@"."];
    return [filename substringWithRange:NSMakeRange(startOfDate.location + 1, endOfDate.location - startOfDate.location - 1)];
}

- (void)startOauthFlow {
    [self.authenticationWindow setIsVisible:TRUE];

    [_windowController signInSheetModalForWindow:[self authenticationWindow]
                                        delegate:self
                                finishedSelector:@selector(windowController:finishedWithAuth:error:)];

    [self.authenticationWindow setWindowController:_windowController];
    [self.authenticationWindow setLevel:NSFloatingWindowLevel];
    [_windowController showWindow:self.authenticationWindow];
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
    BOOL didAuth = [glukitAuth canAuthorize];

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
        NSLog(@"Stopping sync manager...");
        // Get the SyncManager
        [syncManager stop];
        syncManager = nil;
    }
}

#pragma mark - SyncTag persistence handling methods

- (NSString *)pathForFilename:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *folder = [self glukitRoot];

    if (![fileManager fileExistsAtPath:folder]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error creating directory to hold configuration: %@", error);
        };

    }

    return [folder stringByAppendingPathComponent:filename];
}

- (NSString *)glukitRoot {
    NSString *folder = @"~/Library/Application Support/Glukloader/";
    folder = [folder stringByExpandingTildeInPath];
    return folder;
}

- (void)saveSyncTagToDisk:(SyncTag *)tag {
    NSString *path = [self pathForStateFile];

    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];

    [rootObject setValue:tag forKey:SYNC_TAG_KEY];
    [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
    NSLog(@"Saved tag [%@] to disk", tag);
}

- (NSString *)pathForStateFile {
    return [self pathForFilename:@"Glukloader.state"];
}

- (SyncTag *)loadDataFromDisk {
    NSString *path = [self pathForStateFile];
    NSDictionary *rootObject;

    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    SyncTag *tag = [rootObject valueForKey:SYNC_TAG_KEY];
    NSLog(@"Loaded tag [%@] from disk", tag);
    return tag;
}

#pragma mark - UIWebViewDelegate methods

- (void)syncStarted:(SyncEvent *)event {
    NSLog(@"Sync started at %@", [NSDate date]);
    syncInProgress = YES;
    [self updateGlukloaderIcon];
}

- (void)errorReadingReceiver:(SyncEvent *)event {
    NSLog(@"Error received");
    syncInProgress = NO;
    // TODO Change icon to warning about failure?
}

- (void)syncProgress:(SyncProgressEvent *)event {
    NSLog(@"Sync progressing");
    syncInProgress = YES;
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

    RACSignal *glucoseTransmit = [self signalForDataTransmitOfRecords:glukitReads endpoint:GLUCOSE_READ_ENDPOINT recordType:GLUCOSE_READ_TYPE];
    RACSignal *calibrationTransmit = [self signalForDataTransmitOfRecords:calibrationReads endpoint:CALIBRATIONS_ENDPOINT recordType:CALIBRATION_READ_TYPE];
    RACSignal *injectionTransmit = [self signalForDataTransmitOfRecords:injections endpoint:INJECTIONS_ENDPOINT recordType:INJECTION_TYPE];
    RACSignal *exerciseTransmit = [self signalForDataTransmitOfRecords:exercises endpoint:EXERCISES_ENDPOINT recordType:EXERCISE_TYPE];
    RACSignal *mealsTransmit = [self signalForDataTransmitOfRecords:meals endpoint:MEALS_ENDPOINT recordType:MEALS_TYPE];
    RACSignal *combined = [RACSignal merge:@[glucoseTransmit, calibrationTransmit, injectionTransmit, exerciseTransmit, mealsTransmit]];

    [combined subscribeError:^(NSError *error) {
        // TODO : Flag error with user action?
        // This resets the manager and discards the synctag so we
        // get to retry sending the data
        [self stopSyncManagerIfEnabled];
        syncInProgress = NO;
        [self updateGlukloaderIcon];
    }              completed:^{
        // Commit the data sync by saving the sync tag and writing a log of the
        // uploaded data on local disk
        BOOL writeSuccess = [self writeDataLogToDisk:glukitReads calibrationReads:calibrationReads injections:injections exercises:exercises meals:meals];
        if (writeSuccess) {
            [self saveSyncTagToDisk:syncTag];
        }

        syncInProgress = NO;
        [self updateGlukloaderIcon];
    }];
}

- (BOOL)writeDataLogToDisk:(NSArray *)glukitReads calibrationReads:(NSArray *)calibrationReads injections:(NSArray *)injections exercises:(NSArray *)exercises meals:(NSArray *)meals {
    BOOL success = [self writeDataLogForRecordType:glukitReads recordType:GLUCOSE_READ_TYPE];
    success = success && [self writeDataLogForRecordType:calibrationReads recordType:CALIBRATION_READ_TYPE];
    success = success && [self writeDataLogForRecordType:injections recordType:INJECTION_TYPE];
    success = success && [self writeDataLogForRecordType:exercises recordType:EXERCISE_TYPE];
    success = success && [self writeDataLogForRecordType:meals recordType:MEALS_TYPE];

    return success;
}

- (BOOL)writeDataLogForRecordType:(NSArray *)records recordType:(NSString *const)recordType {
    if ([records count] == 0) {
        NSLog(@"Skipping write log since we have no records for [%s]", [recordType UTF8String]);
        return YES;
    }

    NSObject *firstRecord = [records objectAtIndex:0];
    GlukitTime *glukitTime = nil;
    if (recordType == GLUCOSE_READ_TYPE) {
        glukitTime = [(GlukitGlucoseRead *) firstRecord time];
    } else if (recordType == CALIBRATION_READ_TYPE) {
        glukitTime = [(GlukitCalibrationRead *) firstRecord time];
    } else if (recordType == EXERCISE_TYPE) {
        glukitTime = [(GlukitExercise *) firstRecord time];
    } else if (recordType == INJECTION_TYPE) {
        glukitTime = [(GlukitInjection *) firstRecord time];
    } else if (recordType == MEALS_TYPE) {
        glukitTime = [(GlukitMeal *) firstRecord time];
    }

    NSDate *firstRecordTime = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[glukitTime timestamp] longLongValue] / 1000];
    NSString *recordTypeFilename = [self fileNameForRecordType:recordType firstRecordDate:firstRecordTime];
    NSString *fullPath = [self pathForFilename:recordTypeFilename];
    NSArray *dictionaries = [ModelConverter JSONArrayFromModels:records];
    NSError *error;
    NSString *dataLog = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

    if (error == nil) {
        BOOL result = [dataLog writeToFile:fullPath
                                atomically:NO
                                  encoding:NSStringEncodingConversionAllowLossy
                                     error:&error];
        if (!result) {
            NSLog(@"Failed to write log of records to [%s]: %@", [fullPath UTF8String], error);
            return NO;
        } else {
            NSLog(@"Wrote [%lu] records of [%s] to [%s]",
                    [records count],
                    [recordType UTF8String],
                    [fullPath UTF8String]);
        }

        return YES;
    } else {
        NSLog(@"Failed to encode records as json: %@", error);
        return NO;
    }
}

- (NSString *)fileNameForRecordType:(NSString *const)recordType firstRecordDate:(NSDate *)firstRecordTime {
    return [NSString stringWithFormat:@"%s-%s.json", [recordType UTF8String],
                                      [[filenameDateFormatter stringFromDate:firstRecordTime] UTF8String]];
}

- (void)receiverPlugged:(ReceiverEvent *)event {
    NSLog(@"Received plugged in");
    receiverPluggedIn = YES;
    [self updateGlukloaderIcon];
}

- (void)receiverUnplugged:(ReceiverEvent *)event {
    NSLog(@"Received unplugged");
    receiverPluggedIn = NO;
    [self updateGlukloaderIcon];
}

- (RACSignal *)signalForDataTransmitOfRecordsFromFile:(NSString *)file endpoint:(NSString *)endpoint recordType:(NSString *)recordType modelClass:(Class)modelClass {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSError *err;

        NSData *data = [NSData dataWithContentsOfFile:[self pathForFilename:file] options:NSDataReadingMappedIfSafe error:&err];
        if (err != nil) {
            [subscriber sendError:err];
            return nil;
        }
        NSArray *array = [JsonEncoder decodeArrayToJSON:data error:&err];
        if (err != nil) {
            [subscriber sendError:err];
            return nil;
        }

        NSArray *records = [ModelConverter modelsOfClass:modelClass fromJSONArray:array error:&err];
        if (err != nil) {
            [subscriber sendError:err];
            return nil;
        }

        [self transmitRecords:records endpoint:endpoint recordType:recordType subscriber:subscriber];
        return nil;
    }];
}

- (RACSignal *)signalForDataTransmitOfRecords:(NSArray *)records endpoint:(NSString *)endpoint recordType:(NSString *)recordType {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        [self transmitRecords:records endpoint:endpoint recordType:recordType subscriber:subscriber];
        return nil;
    }];
}

- (void)transmitRecords:(NSArray *)records endpoint:(NSString *)endpoint recordType:(NSString *)recordType subscriber:(id <RACSubscriber>)subscriber {
    if ([records count] > 0) {
            NSArray *dictionaries = [ModelConverter JSONArrayFromModels:records];
            NSError *error;
            NSString *requestBody = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

            if (error == nil) {
                //NSLog(@"Will be posting [%s] records as this\n%s", [recordType UTF8String], [requestBody UTF8String]);
            }

            NSData *payload = [requestBody dataUsingEncoding:NSUTF8StringEncoding];

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:payload];

            GTMHTTPFetcher *fetcher = [self newFetcherForRequest:request];
            [fetcher setRetryEnabled:NO];
            [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *responseError) {
                if (responseError != nil && [responseError code] != 200) {
                    NSLog(@"Error accessing ressource, removing auth from keychain. "
                            "Payload was [%@] for request [%@] and error [%li] was %@",
                            data, [responseError userInfo], [responseError code], responseError.localizedDescription);
                    [self clearAuthentication];
                    [subscriber sendError:responseError];
                } else {
                    NSLog(@"Success, got response [%s]", [[NSString stringWithUTF8String:[data bytes]] UTF8String]);
                    [self updateRefreshTokenInKeychainIfRequired];
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                }
            }];
        } else {
            NSLog(@"No [%s] records to transmit", [recordType UTF8String]);
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }
}

- (void)clearAuthentication {
    [self.authenticationWindow setIsVisible:YES];
    [GTMOAuth2WindowController removeAuthFromKeychainForName:GLUKIT_KEYCHAIN_NAME];
}

- (GTMHTTPFetcher *)newFetcherForRequest:(NSMutableURLRequest *)request {
    GTMHTTPFetcher *fetcher = [[GTMHTTPFetcher alloc] initWithRequest:request];
    [fetcher setAuthorizer:glukitAuth];
    return fetcher;
}
@end
