#import <bloodSheltie/TimestampedValue.h>
#import <bloodSheltie/GlucoseRead.h>
#import "ModelConverter.h"
#import "GlukitGlucoseRead.h"


@implementation ModelConverter {

}
+ (NSArray *)convertGlucoseReads:(NSArray *)glucoseReads {
    NSMutableArray *glukitReads = [NSMutableArray arrayWithCapacity:[glucoseReads count]];

    for (id read in glucoseReads) {
        long long timestamp = (long long) ([[read userTime] timeIntervalSince1970] * 1000.0);
        GlukitGlucoseRead *glukitGlucoseRead = [GlukitGlucoseRead readWithTimestamp:timestamp timezone:[read timezone] value:[read glucoseValue] unit:[self getUnit:[read glucoseMeasurementUnit]]];
        [glukitReads addObject:glukitGlucoseRead];
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
}

+ (NSArray *)convertCalibrationReads:(NSArray *)calibrationReads {
    return nil;
}

+ (NSArray *)convertInjections:(NSArray *)injections {
    return nil;
}

+ (NSArray *)convertCarbs:(NSArray *)carbs {
    return nil;
}

+ (NSArray *)convertExercises:(NSArray *)exercises {
    return nil;
}

@end