#import "GlukitMeal.h"


@implementation GlukitMeal {

}
- (instancetype)initWithTime:(GlukitTime *)time carbs:(float)carbs proteins:(float)proteins fat:(float)fat saturatedFat:(float)saturatedFat {
    self = [super init];
    if (self) {
        _time = time;
        _carbs=carbs;
        _proteins=proteins;
        _fat=fat;
        _saturatedFat=saturatedFat;
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.time=%@", self.time];
    [description appendFormat:@", self.carbs=%f", self.carbs];
    [description appendFormat:@", self.proteins=%f", self.proteins];
    [description appendFormat:@", self.fat=%f", self.fat];
    [description appendFormat:@", self.saturatedFat=%f", self.saturatedFat];

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


+ (instancetype)mealWithTime:(GlukitTime *)time carbs:(float)carbs proteins:(float)proteins fat:(float)fat saturatedFat:(float)saturatedFat {
    return [[self alloc] initWithTime:time carbs:carbs proteins:proteins fat:fat saturatedFat:saturatedFat];
}

+ (NSValueTransformer *)timeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[GlukitTime class]];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"time" : @"time",
            @"carbs" : @"carbohydrates",
            @"proteins" : @"proteins",
            @"fat" : @"fat",
            @"saturatedFat" : @"saturatedFat"
    };
}

@end