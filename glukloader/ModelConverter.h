#import <Foundation/Foundation.h>
#import "GlukitGlucoseRead.h"
#import "GlukitInjection.h"
#import "GlukitCalibrationRead.h"
#import "GlukitMeal.h"
#import "GlukitExercise.h"
#import <bloodSheltie/GlucoseRead.h>
#import <bloodSheltie/InsulinInjection.h>
#import <bloodSheltie/FoodEvent.h>
#import <bloodSheltie/MeterRead.h>
#import <bloodSheltie/ExerciseEvent.h>

@interface ModelConverter : NSObject
+(NSArray *) convertGlucoseReads:(NSArray *) glucoseReads;
+(GlukitGlucoseRead *) convertGlucoseRead:(GlucoseRead *) glucoseRead;

+(NSArray *) convertCalibrationReads:(NSArray *) calibrationReads;
+(GlukitCalibrationRead *) convertCalibrationRead:(MeterRead *) calibrationRead;

+(NSArray *) convertInjections:(NSArray *) injections;
+(GlukitInjection *) convertInjection:(InsulinInjection *) injection;

+(NSArray *)convertMeals:(NSArray *)foodEvents;
+(GlukitMeal *)convertMeal:(FoodEvent *)foodEvent;

+(NSArray *) convertExercises:(NSArray *) exercises;
+(GlukitExercise *) convertExercise:(ExerciseEvent *) exercise;


+ (NSArray *)JSONArrayFromModels:(NSArray *)models;

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray error:(NSError **)error;
@end