#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>


@interface GlukitTime : MTLModel <MTLJSONSerializing>
@property(readonly) NSNumber *timestamp;
@property(readonly) NSTimeZone *timezone;

- (instancetype)initWithTimezone:(NSTimeZone *)timezone timestamp:(NSNumber *)timestamp;

- (NSString *)description;

+ (instancetype)timeWithTimezone:(NSTimeZone *)timezone timestamp:(NSNumber *)timestamp;

@end