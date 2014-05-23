#import <Mantle/MTLModel+NSCoding.h>
#import "GlukitGlucoseRead.h"


@implementation GlukitGlucoseRead {

}
- (instancetype)initWithTimestamp:(long long)timestamp timezone:(NSTimeZone *)timezone value:(float)value unit:(NSString *)unit {
    self = [super init];
    if (self) {
        _timestamp = timestamp;
        _timezone=timezone;
        _value=value;
        _unit=unit;
    }

    return self;
}

+ (instancetype)readWithTimestamp:(long long)timestamp timezone:(NSTimeZone *)timezone value:(float)value unit:(NSString *)unit {
    return [[self alloc] initWithTimestamp:timestamp timezone:timezone value:value unit:unit];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.value=%f", self.value];
    [description appendFormat:@", self.unit=%@", self.unit];
    [description appendFormat:@", self.timestamp=%qi", self.timestamp];
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


@end