//
//  org_glukitAppDelegate.h
//  glukloader
//
//  Created by Alexandre Normand on 2014-03-05.
//  Copyright (c) 2014 glukit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <bloodSheltie/SyncEventObserver.h>

@class GrowlDelegate;

typedef BOOL (^transmitFunction)(NSArray *, NSString *, NSString *);

static NSString *const CODE_KEY = @"code";
static NSString *const STATE_KEY = @"state";

static NSString *const SYNC_TAG_KEY = @"syncTag";

static NSString *const GLUCOSE_READ_TYPE = @"glucoseReads";

static NSString *const CALIBRATION_READ_TYPE = @"calibrationReads";

static NSString *const INJECTION_TYPE = @"injections";

static NSString *const EXERCISE_TYPE = @"exercises";

static NSString *const MEALS_TYPE = @"meals";

static NSString *const GLUCOSE_READ_ENDPOINT = @"https://glukit.appspot.com/v1/glucosereads";

static NSString *const CALIBRATIONS_ENDPOINT = @"https://glukit.appspot.com/v1/calibrations";

static NSString *const INJECTIONS_ENDPOINT = @"https://glukit.appspot.com/v1/injections";

static NSString *const EXERCISES_ENDPOINT = @"https://glukit.appspot.com/v1/exercises";

static NSString *const MEALS_ENDPOINT = @"https://glukit.appspot.com/v1/meals";

@interface org_glukitAppDelegate : NSObject <NSApplicationDelegate, SyncEventObserver>

@property (strong, nonatomic) NSStatusItem *statusBar;

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *authenticationMenuItem;
@property (assign) IBOutlet NSMenuItem *autoStartMenuItem;
@property (strong, nonatomic) IBOutlet NSWindow *authenticationWindow;
@property (strong, nonatomic) IBOutlet NSWindow *progressWindow;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong, nonatomic) IBOutlet WebView *loginWebView;


@end
