#import "GlukitTime.h"


@implementation GlukitTime {

}
- (instancetype)initWithTimezone:(NSTimeZone *)timezone timestamp:(NSNumber *)timestamp {
    self = [super init];
    if (self) {
        _timezone = timezone;
        _timestamp = timestamp;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.timestamp=%@", self.timestamp];
    [description appendFormat:@", self.timezone=%@", self.timezone];

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

+ (instancetype)timeWithTimezone:(NSTimeZone *)timezone timestamp:(NSNumber *)timestamp {
    return [[self alloc] initWithTimezone:timezone timestamp:timestamp];
}

+ (NSValueTransformer *)timezoneJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *name) {
        return [NSTimeZone timeZoneWithName:name];
    }                                                    reverseBlock:^(NSTimeZone *timezone) {
        return [[timezone name] substringFromIndex:3];
    }];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"timestamp" : @"timestamp",
            @"timezone" : @"timezone"
    };
}

@end