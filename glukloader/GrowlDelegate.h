#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

static NSString *const SYNC_STARTED_NOTIFICATION = @"SyncStarted";
static NSString *const SYNC_COMPLETED_SUCCESSFULLY = @"SyncCompletedSuccessfully";
static NSString *const SYNC_ERROR = @"SyncError";
static NSString *const UPLOAD_STARTED = @"UploadStarted";

@interface GrowlDelegate : NSObject <GrowlApplicationBridgeDelegate>

+ (GrowlDelegate *)instance;

- (NSDictionary *) registrationDictionaryForGrowl;

- (NSString *) applicationNameForGrowl;

@end