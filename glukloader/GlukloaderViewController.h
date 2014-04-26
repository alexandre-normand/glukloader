//
//  GlukloaderViewController.h
//  glukloader
//
//  Created by Alexandre Normand on 2014-04-24.
//  Copyright (c) 2014 glukit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NSValidatedToolbarItem <NSValidatedUserInterfaceItem>

- (NSString *)toolTip;
- (void)setToolTip:(NSString *)theToolTip;
@end

@interface GlukloaderViewController : NSViewController

@end
