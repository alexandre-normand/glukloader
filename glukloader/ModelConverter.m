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
    GlukitTime *time = [GlukitTime timeWithTimezone:[ModelConverter getTimezoneIdFromTimezone:[glucoseRead timezone]
                                                                                  atTimestamp:[glucoseRead timestamp]]
                                          timestamp:[NSNumber numberWithLongLong:[glucoseRead timestamp]]];
    return [GlukitGlucoseRead readWithTime:time
                                     value:[glucoseRead glucoseValue]
                                      unit:[self getUnit:[glucoseRead glucoseMeasurementUnit]]];
}

+ (NSArray *)convertCalibrationReads:(NSArray *)calibrationReads {
    NSMutableArray *glukitCalibrations = [NSMutableArray arrayWithCapacity:[calibrationReads count]];

    for (id calibration in calibrationReads) {
        [glukitCalibrations addObject:[self convertCalibrationRead:calibration]];
    }
    return glukitCalibrations;
}

+ (GlukitCalibrationRead *)convertCalibrationRead:(MeterRead *)calibrationRead {
    GlukitTime *time = [GlukitTime timeWithTimezone:[ModelConverter getTimezoneIdFromTimezone:[calibrationRead timezone]
                                                                                  atTimestamp:[calibrationRead timestamp]]
                                          timestamp:[NSNumber numberWithLongLong:[calibrationRead timestamp]]];
    return [GlukitCalibrationRead calibrationReadWithTime:time
                                                    value:[calibrationRead meterRead]
                                                     unit:[self getUnit:[calibrationRead glucoseMeasurementUnit]]];
}

+ (NSArray *)convertInjections:(NSArray *)injections {
    NSMutableArray *glukitInjections = [NSMutableArray arrayWithCapacity:[injections count]];

    for (id injection in injections) {
        [glukitInjections addObject:[self convertInjection:injection]];
    }
    return glukitInjections;
}

+ (GlukitInjection *)convertInjection:(InsulinInjection *)injection {
    GlukitTime *time = [GlukitTime timeWithTimezone:[ModelConverter getTimezoneIdFromTimezone:[injection timezone]
                                                                                  atTimestamp:[injection timestamp]]
                                          timestamp:[NSNumber numberWithLongLong:[injection timestamp]]];
    return [GlukitInjection injectionWithTime:time
                                        units:[injection unitValue]
                                  insulinName:[injection insulinName]
                                  insulinType:[self getInsulinType:[injection insulinType]]];
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
    GlukitTime *time = [GlukitTime timeWithTimezone:[ModelConverter getTimezoneIdFromTimezone:[foodEvent timezone]
                                                                                  atTimestamp:[foodEvent timestamp]]
                                          timestamp:[NSNumber numberWithLongLong:[foodEvent timestamp]]];
    return [GlukitMeal mealWithTime:time
                              carbs:[foodEvent carbohydrates]
                           proteins:[foodEvent proteins]
                                fat:[foodEvent fat]
                       saturatedFat:-1];
}

+ (NSArray *)convertExercises:(NSArray *)exercises {
    NSMutableArray *glukitExercises = [NSMutableArray arrayWithCapacity:[exercises count]];

    for (id exercise in exercises) {
        [glukitExercises addObject:[self convertExercise:exercise]];
    }
    return glukitExercises;
}

+ (GlukitExercise *)convertExercise:(ExerciseEvent *)exercise {
    GlukitTime *time = [GlukitTime timeWithTimezone:[ModelConverter getTimezoneIdFromTimezone:[exercise timezone]
                                                                                  atTimestamp:[exercise timestamp]]
                                          timestamp:[NSNumber numberWithLongLong:[exercise timestamp]]];
    return [GlukitExercise exerciseWithTime:time
                          durationInMinutes:(int) ([exercise duration] / 60.f)
                                  intensity:[self getIntensity:[exercise intensity]]
                        exerciseDescription:[exercise details]];
}

+ (NSString *)getTimezoneIdFromTimezone:(NSTimeZone *)timezone atTimestamp:(long long int)timestamp {
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) (timestamp / 1000.f)];
    NSInteger secondsFromGMT = [timezone secondsFromGMTForDate:time];
    NSInteger hoursOffset = secondsFromGMT / 3600;
    NSInteger minutesOffset = (secondsFromGMT - hoursOffset * 3600) / 60;
    return [NSString stringWithFormat:@"%+.2d%.2d", (int) hoursOffset, (int) minutesOffset];
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

+ (NSArray *)JSONArrayFromModels:(NSArray *)models {
	NSParameterAssert(models != nil);
	NSParameterAssert([models isKindOfClass:NSArray.class]);
    
	NSMutableArray *JSONArray = [NSMutableArray arrayWithCapacity:models.count];
	for (MTLModel<MTLJSONSerializing> *model in models) {
		NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:model];
		if (JSONDictionary == nil) return nil;
        
		[JSONArray addObject:JSONDictionary];
	}
    
	return JSONArray;
}

+ (NSArray *)modelsOfClass:(Class)modelClass fromJSONArray:(NSArray *)JSONArray error:(NSError **)error {
    if (JSONArray == nil || ![JSONArray isKindOfClass:NSArray.class]) {
        if (error != NULL) {
            NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Missing JSON array", @""),
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"%@ could not be created because an invalid JSON array was provided: %@", @""), NSStringFromClass(modelClass), JSONArray.class],
            };
            *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONDictionary userInfo:userInfo];
        }
        return nil;
    }

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:JSONArray.count];
    for (NSDictionary *JSONDictionary in JSONArray){
        MTLModel *model = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary error:error];

        if (model == nil) return nil;

        [models addObject:model];
    }

    return models;
}



@end