#import "GlukitCalibrationRead.h"


@implementation GlukitCalibrationRead {

}
- (instancetype)initWithTime:(GlukitTime *)time value:(float)value {
    self = [super init];
    if (self) {
        _time = time;
        _value=value;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.value=%f", self.value];
    [description appendFormat:@", self.time=%@", self.time];

    NSMutableString *superDescription = [[super description] mutableCopy];
    NSUInteger length = [superDescription length];

    if (length > 0 && [superDescription characterAtIndex:length - 1] == '>') {
        [superDescription insertString:@", " atIndex:length - 1];
        [superDescription insertString:description atIndex:length + 1];
        return superDescription;
    }
    else {
        return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), description];
    }
}


+ (instancetype)calibrationReadWithTime:(GlukitTime *)time value:(float)value {
    return [[self alloc] initWithTime:time value:value];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GlukitTime class]];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"time" : @"time",
            @"value" : @"value"
    };
}


@end