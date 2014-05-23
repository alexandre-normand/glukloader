#import <Foundation/Foundation.h>
#import <Mantle/MTLJSONAdapter.h>


@interface GlukitGlucoseRead : MTLModel <MTLJSONSerializing>
@property(readonly) float value;
@property(readonly) NSString *unit;
@property(readonly) long long timestamp;
@property(readonly) NSTimeZone *timezone;

- (instancetype)initWithTimestamp:(long long)timestamp timezone:(NSTimeZone *)timezone value:(float)value unit:(NSString *)unit;

- (NSString *)description;

+ (instancetype)readWithTimestamp:(long long)timestamp timezone:(NSTimeZone *)timezone value:(float)value unit:(NSString *)unit;


@end