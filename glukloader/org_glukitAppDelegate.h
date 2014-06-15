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

typedef BOOL (^transmitFunction)(NSArray *, NSString *, NSString *);

static NSString *const CODE_KEY = @"code";
static NSString *const STATE_KEY = @"state";

static NSString *const SYNC_TAG_KEY = @"syncTag";

static NSString *const GLUCOSE_READ_TYPE = @"GlucoseReads";

static NSString *const CALIBRATION_READ_TYPE = @"CalibrationReads";

static NSString *const INJECTION_TYPE = @"Injections";

static NSString *const EXERCISE_TYPE = @"Exercises";

static NSString *const MEALS_TYPE = @"Meals";

@interface org_glukitAppDelegate : NSObject <NSApplicationDelegate, SyncEventObserver>

@property (strong, nonatomic) NSStatusItem *statusBar;

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *authenticationMenuItem;
@property (assign) IBOutlet NSMenuItem *autoStartMenuItem;
@property (strong, nonatomic) IBOutlet NSWindow *authenticationWindow;
@property (strong, nonatomic) IBOutlet WebView *loginWebView;


@end
