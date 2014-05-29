#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>


@interface GlukitTime : MTLModel <MTLJSONSerializing>
@property(readonly) long long timestamp;
@property(readonly) NSTimeZone *timezone;

- (instancetype)initWithTimezone:(NSTimeZone *)timezone timestamp:(long long int)timestamp;

+ (instancetype)timeWithTimezone:(NSTimeZone *)timezone timestamp:(long long int)timestamp;

- (NSString *)description;

@end