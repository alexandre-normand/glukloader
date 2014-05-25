#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "GlukitTime.h"


@interface GlukitMeal : MTLModel <MTLJSONSerializing>
@property(readonly) GlukitTime *time;
@property(readonly) float carbs;
@property(readonly) float proteins;
@property(readonly) float fat;
@property(readonly) float saturatedFat;

- (instancetype)initWithTime:(GlukitTime *)time carbs:(float)carbs proteins:(float)proteins fat:(float)fat saturatedFat:(float)saturatedFat;

+ (instancetype)mealWithTime:(GlukitTime *)time carbs:(float)carbs proteins:(float)proteins fat:(float)fat saturatedFat:(float)saturatedFat;

- (NSString *)description;

@end