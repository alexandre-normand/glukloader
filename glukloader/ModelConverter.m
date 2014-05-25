#import <bloodSheltie/TimestampedValue.h>
#import <bloodSheltie/GlucoseRead.h>
#import "ModelConverter.h"


@implementation ModelConverter {

}
+ (NSArray *)convertGlucoseReads:(NSArray *)glucoseReads {
    NSMutableArray *glukitReads = [NSMutableArray arrayWithCapacity:[glucoseReads count]];

    for (id read in glucoseReads) {
        [glukitReads addObject:[self convertGlucoseRead:read]];
    }
    return glukitReads;
}

+ (NSString *)getUnit:(GlucoseMeasurementUnit)unit {
    switch (unit) {
        case UNKNOWN_MEASUREMENT_UNIT:
            return nil;
        case MMOL_PER_L:
            return @"mmolPerL";
        case MG_PER_DL:
            return @"mgPerDL";
    }

    return nil;
}

+ (GlukitGlucoseRead *)convertGlucoseRead:(GlucoseRead *)glucoseRead {
    long long timestamp = (long long) ([[glucoseRead userTime] timeIntervalSince1970] * 1000.0);
    GlukitTime *time = [GlukitTime timeWithTimezone:[glucoseRead timezone] timestamp:timestamp];
    return [GlukitGlucoseRead readWithTime:time value:[glucoseRead glucoseValue] unit:[self getUnit:[glucoseRead glucoseMeasurementUnit]]];
}

+ (NSArray *)convertCalibrationReads:(NSArray *)calibrationReads {
    NSMutableArray *glukitCalibrations = [NSMutableArray arrayWithCapacity:[calibrationReads count]];

    for (id calibration in calibrationReads) {
        [glukitCalibrations addObject:[self convertCalibrationRead:calibration]];
    }
    return glukitCalibrations;
}

+ (GlukitCalibrationRead *)convertCalibrationRead:(MeterRead *)calibrationRead {
    long long timestamp = (long long) ([[calibrationRead userTime] timeIntervalSince1970] * 1000.0);
    GlukitTime *time = [GlukitTime timeWithTimezone:[calibrationRead timezone] timestamp:timestamp];
    return [GlukitCalibrationRead calibrationReadWithTime:time value:[calibrationRead meterRead]];
}

+ (NSArray *)convertInjections:(NSArray *)injections {
    NSMutableArray *glukitInjections = [NSMutableArray arrayWithCapacity:[injections count]];

    for (id injection in injections) {
        [glukitInjections addObject:[self convertInjection:injection]];
    }
    return glukitInjections;
}

+ (GlukitInjection *)convertInjection:(InsulinInjection *)injection {
    long long timestamp = (long long) ([[injection userTime] timeIntervalSince1970] * 1000.0);
    GlukitTime *time = [GlukitTime timeWithTimezone:[injection  timezone] timestamp:timestamp];
    return [GlukitInjection injectionWithTime:time units:[injection unitValue] insulinName:[injection insulinName] insulinType:[self getInsulinType:[injection insulinType]]];
}

+ (NSString *)getInsulinType:(InsulinType)insulinType {
    switch (insulinType) {
        case UnknownInsulinType:
            return nil;
        case Bolus:
            return @"bolus";
        case Basal:
            return @"basal";
    }

    return nil;
}

+ (NSArray *)convertMeals:(NSArray *)foodEvents {
    NSMutableArray *glukitMeals = [NSMutableArray arrayWithCapacity:[foodEvents count]];

    for (id foodEvent in foodEvents) {
        [glukitMeals addObject:[self convertMeal:foodEvent]];
    }
    return glukitMeals;
}

+ (GlukitMeal *)convertMeal:(FoodEvent *)foodEvent {
    long long timestamp = (long long) ([[foodEvent userTime] timeIntervalSince1970] * 1000.0);
    GlukitTime *time = [GlukitTime timeWithTimezone:[foodEvent timezone] timestamp:timestamp];
    return [GlukitMeal mealWithTime:time carbs:[foodEvent carbohydrates] proteins:[foodEvent proteins] fat:[foodEvent fat] saturatedFat:0.f];
}

+ (NSArray *)convertExercises:(NSArray *)exercises {
    NSMutableArray *glukitExercises = [NSMutableArray arrayWithCapacity:[exercises count]];

    for (id exercise in exercises) {
        [glukitExercises addObject:[self convertExercise:exercise]];
    }
    return glukitExercises;
}

+ (GlukitExercise *)convertExercise:(ExerciseEvent *)exercise {
    long long timestamp = (long long) ([[exercise userTime] timeIntervalSince1970] * 1000.0);
    GlukitTime *time = [GlukitTime timeWithTimezone:[exercise timezone] timestamp:timestamp];
    return [GlukitExercise exerciseWithTime:time durationInMinutes:(int) ([exercise duration] / 60.f) intensity:[self getIntensity:[exercise intensity]] exerciseDescription:[exercise details]];
}

+ (NSString *)getIntensity:(Intensity)intensity {
    switch (intensity) {
        case UnknownExerciseIntensity:
            return nil;
        case LightExercise:
            return @"light";
        case MediumExercise:
            return @"medium";
        case HeavyExercise:
            return @"heavy";
    }

    return nil;
}


@end