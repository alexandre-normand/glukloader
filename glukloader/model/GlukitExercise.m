#import "GlukitExercise.h"


@implementation GlukitExercise {

}
- (instancetype)initWithTime:(GlukitTime *)time durationInMinutes:(int)durationInMinutes intensity:(NSString *)intensity exerciseDescription:(NSString *)exerciseDescription {
    self = [super init];
    if (self) {
        _time = time;
        _durationInMinutes=durationInMinutes;
        _intensity=intensity;
        _exerciseDescription=exerciseDescription;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.time=%@", self.time];
    [description appendFormat:@", self.duration=%d", self.durationInMinutes];
    [description appendFormat:@", self.intensity=%@", self.intensity];
    [description appendFormat:@", self.exerciseDescription=%@", self.exerciseDescription];

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


+ (instancetype)exerciseWithTime:(GlukitTime *)time durationInMinutes:(int)durationInMinutes intensity:(NSString *)intensity exerciseDescription:(NSString *)exerciseDescription {
    return [[self alloc] initWithTime:time durationInMinutes:durationInMinutes intensity:intensity exerciseDescription:exerciseDescription];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GlukitTime class]];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"time" : @"time",
            @"exerciseDescription" : @"description",
            @"durationInMinutes" : @"durationInMinutes",
            @"intensity" : @"intensity"
    };
}


@end