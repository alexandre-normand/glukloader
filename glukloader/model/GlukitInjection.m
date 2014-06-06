#import "GlukitInjection.h"
#import <Mantle/Mantle.h>


@implementation GlukitInjection {

}
- (instancetype)initWithTime:(GlukitTime *)time units:(float)units insulinName:(NSString *)insulinName insulinType:(NSString *)insulinType {
    self = [super init];
    if (self) {
        _time = time;
        _units=units;
        _insulinName=insulinName;
        _insulinType=insulinType;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.time=%@", self.time];
    [description appendFormat:@", self.units=%f", self.units];
    [description appendFormat:@", self.insulinName=%@", self.insulinName];
    [description appendFormat:@", self.insulinType=%@", self.insulinType];
    [description appendString:@">"];
    return description;
}


+ (instancetype)injectionWithTime:(GlukitTime *)time units:(float)units insulinName:(NSString *)insulinName insulinType:(NSString *)insulinType {
    return [[self alloc] initWithTime:time units:units insulinName:insulinName insulinType:insulinType];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GlukitTime class]];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"time" : @"time",
            @"units" : @"units",
            @"insulinName" : @"insulinName",
            @"insulinType" : @"insulinType"
    };
}

@end