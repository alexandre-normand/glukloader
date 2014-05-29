#import <Foundation/Foundation.h>
#import "GlukitTime.h"

@interface GlukitInjection : MTLModel <MTLJSONSerializing>
@property(readonly) GlukitTime *time;
@property(readonly) float units;
@property(readonly) NSString *insulinName;
@property(readonly) NSString *insulinType;

- (instancetype)initWithTime:(GlukitTime *)time units:(float)units insulinName:(NSString *)insulinName insulinType:(NSString *)insulinType;

+ (instancetype)injectionWithTime:(GlukitTime *)time units:(float)units insulinName:(NSString *)insulinName insulinType:(NSString *)insulinType;

- (NSString *)description;

@end