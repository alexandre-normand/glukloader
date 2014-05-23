#import <Foundation/Foundation.h>


@interface ModelConverter : NSObject
+(NSArray *) convertGlucoseReads:(NSArray *) glucoseReads;
+(NSArray *) convertCalibrationReads:(NSArray *) calibrationReads;
+(NSArray *) convertInjections:(NSArray *) injections;
+(NSArray *) convertCarbs:(NSArray *) carbs;
+(NSArray *) convertExercises:(NSArray *) exercises;

@end