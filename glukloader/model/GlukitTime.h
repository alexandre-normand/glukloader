#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>


@interface GlukitTime : MTLModel <MTLJSONSerializing>
@property(readonly) NSNumber *timestamp;
@property(readonly) NSString *timezone;

- (instancetype)initWithTimezone:(NSString *)timezone timestamp:(NSNumber *)timestamp;

- (NSString *)description;

+ (instancetype)timeWithTimezone:(NSString *)timezone timestamp:(NSNumber *)timestamp;

@end