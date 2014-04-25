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

static NSString *const CODE_KEY = @"code";
static NSString *const STATE_KEY = @"state";

@interface org_glukitAppDelegate : NSObject <NSApplicationDelegate, SyncEventObserver>

@property (strong, nonatomic) NSStatusItem *statusBar;

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *authenticationMenuItem;
@property (strong, nonatomic) IBOutlet NSWindow *authenticationWindow;
@property (strong, nonatomic) IBOutlet WebView *loginWebView;


@end
