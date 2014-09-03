#import "GrowlDelegate.h"


@implementation GrowlDelegate {

}
+ (GrowlDelegate *)instance {
    static GrowlDelegate *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            [GrowlApplicationBridge setGrowlDelegate:_instance];
        }
    }

    return _instance;
}

- (NSDictionary *)registrationDictionaryForGrowl {
    return @{GROWL_NOTIFICATIONS_ALL : @[SYNC_STARTED_NOTIFICATION, SYNC_COMPLETED_SUCCESSFULLY, SYNC_ERROR, UPLOAD_STARTED], GROWL_NOTIFICATIONS_DEFAULT : @[SYNC_STARTED_NOTIFICATION, SYNC_COMPLETED_SUCCESSFULLY, SYNC_ERROR, UPLOAD_STARTED]};
}

- (NSString *)applicationNameForGrowl {
    return @"Glukloader";
}



@end