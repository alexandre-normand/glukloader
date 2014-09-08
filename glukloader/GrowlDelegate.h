#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

static NSString *const SYNC_STARTED_NOTIFICATION = @"SyncStarted";
static NSString *const SYNC_COMPLETED_SUCCESSFULLY = @"SyncCompletedSuccessfully";
static NSString *const SYNC_ERROR = @"SyncError";
static NSString *const UPLOAD_STARTED = @"UploadStarted";
static NSString *const LOGS_EMAILED = @"LogsEmailed";
static NSString *const EMAIL_LOGS_ERROR = @"LogsEmailError";
static NSString *const PREPARING_LOGS = @"PreparingLogs";

@interface GrowlDelegate : NSObject <GrowlApplicationBridgeDelegate>

+ (GrowlDelegate *)instance;

- (NSDictionary *) registrationDictionaryForGrowl;

- (NSString *) applicationNameForGrowl;

@end