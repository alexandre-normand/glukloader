#import <Foundation/Foundation.h>
#import <Mantle/MTLJSONAdapter.h>
#import "GlukitTime.h"

@interface GlukitCalibrationRead : MTLModel <MTLJSONSerializing>

@property(readonly) float value;
@property(readonly) GlukitTime *time;

- (instancetype)initWithTime:(GlukitTime *)time value:(float)value;

+ (instancetype)calibrationReadWithTime:(GlukitTime *)time value:(float)value;

- (NSString *)description;

@end