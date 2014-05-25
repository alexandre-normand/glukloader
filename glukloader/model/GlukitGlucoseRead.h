#import <Foundation/Foundation.h>
#import <Mantle/MTLJSONAdapter.h>
#import "GlukitTime.h"

@interface GlukitGlucoseRead : MTLModel <MTLJSONSerializing>
@property(readonly) float value;
@property(readonly) NSString *unit;
@property(readonly) GlukitTime *time;

- (instancetype)initWithTime:(GlukitTime *)time value:(float)value unit:(NSString *)unit;

+ (instancetype)readWithTime:(GlukitTime *)time value:(float)value unit:(NSString *)unit;

- (NSString *)description;

@end