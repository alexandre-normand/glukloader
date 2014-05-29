#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "GlukitTime.h"

@interface GlukitExercise : MTLModel <MTLJSONSerializing>
@property(readonly) GlukitTime *time;
@property(readonly) int durationInMinutes;
@property(readonly) NSString *intensity;
@property(readonly) NSString *exerciseDescription;

- (instancetype)initWithTime:(GlukitTime *)time durationInMinutes:(int)durationInMinutes intensity:(NSString *)intensity exerciseDescription:(NSString *)exerciseDescription;

+ (instancetype)exerciseWithTime:(GlukitTime *)time durationInMinutes:(int)durationInMinutes intensity:(NSString *)intensity exerciseDescription:(NSString *)exerciseDescription;

- (NSString *)description;
@end