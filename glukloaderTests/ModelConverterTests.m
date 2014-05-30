//
//  ModelConverterTests.m
//  glukloader
//
//  Created by Alexandre Normand on 2014-05-22.
//  Copyright (c) 2014 glukit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <bloodSheltie/GlucoseRead.h>
#import <bloodSheltie/EncodingUtils.h>
#import "ModelConverter.h"
#import "JsonEncoder.h"

@interface ModelConverterTests : XCTestCase

@end

@implementation ModelConverterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGlucoseReadsConversion
{
    NSMutableArray *glucoseRecords = [NSMutableArray array];
    [glucoseRecords addObject:[GlucoseRead valueWithInternalTime:[NSDate dateWithTimeIntervalSinceNow:0] userTime:[NSDate dateWithTimeIntervalSinceNow:200] timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"] value:4.2 unit:MMOL_PER_L]];

    NSArray *glukitGlucoseReads = [ModelConverter convertGlucoseReads:glucoseRecords];
    NSArray *dictionaries = [MTLJSONAdapter JSONArrayFromModels:glukitGlucoseReads];
    NSError *error;
    NSString *json = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

    if (error == nil) {        
        NSLog(@"Reads are %@", json);
    } else {
        XCTFail(@"Error encoding: %@", error);
    }
}

- (void)testInjectionConversion
{
    NSMutableArray *injections = [NSMutableArray array];
    [injections addObject:[InsulinInjection valueWithInternalTime:[NSDate dateWithTimeIntervalSinceNow:0] userTime:[NSDate dateWithTimeIntervalSinceNow:200] userTimezone:[NSTimeZone timeZoneWithName:@"America/Montreal"] eventTime:[NSDate dateWithTimeIntervalSinceNow:130] insulinType:Basal unitValue:1.75 insulinName:@"Humalog"]];

    NSArray *glukitInjections = [ModelConverter convertInjections:injections];
    NSArray *dictionaries = [MTLJSONAdapter JSONArrayFromModels:glukitInjections];
    NSError *error;
    NSString *json = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

    if (error == nil) {
        NSLog(@"Injections are %@", json);
    } else {
        XCTFail(@"Error encoding: %@", error);
    }
}

- (void)testCalibrationConversion
{
    NSMutableArray *calibrations = [NSMutableArray array];
    [calibrations addObject:[MeterRead valueWithInternalTime:[NSDate dateWithTimeIntervalSinceNow:0] userTime:[NSDate dateWithTimeIntervalSinceNow:110] timezone:[NSTimeZone timeZoneWithName:@"America/Montreal"] meterTime:[NSDate dateWithTimeIntervalSinceNow:230] meterRead:75.f glucoseMeasurementUnit:MG_PER_DL]];

    NSArray *glukitCalibrations = [ModelConverter convertCalibrationReads:calibrations];
    NSArray *dictionaries = [MTLJSONAdapter JSONArrayFromModels:glukitCalibrations];
    NSError *error;
    NSString *json = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

    if (error == nil) {
        NSLog(@"Calibrations are %@", json);
    } else {
        XCTFail(@"Error encoding: %@", error);
    }
}

- (void)testMealConversion
{
    NSMutableArray *meals = [NSMutableArray array];
    [meals addObject:[FoodEvent valueWithInternalTime:[NSDate dateWithTimeIntervalSinceNow:0] userTime:[NSDate dateWithTimeIntervalSinceNow:10] userTimezone:[NSTimeZone timeZoneWithName:@"America/Montreal"] eventTime:[NSDate dateWithTimeIntervalSinceNow:210] carbohydrates:10.f proteins:12.f fat:23.f]];

    NSArray *glukitMeals = [ModelConverter convertMeals:meals];
    NSArray *dictionaries = [MTLJSONAdapter JSONArrayFromModels:glukitMeals];
    NSError *error;
    NSString *json = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

    if (error == nil) {
        NSLog(@"Meals are %@", json);
    } else {
        XCTFail(@"Error encoding: %@", error);
    }
}

- (void)testExerciseConversion
{
    NSMutableArray *exercises = [NSMutableArray array];
    [exercises addObject:[ExerciseEvent valueWithInternalTime:[NSDate dateWithTimeIntervalSinceNow:0] userTime:[NSDate dateWithTimeIntervalSinceNow:10] userTimezone:[NSTimeZone timeZoneWithName:@"America/Montreal"] eventTime:[NSDate dateWithTimeIntervalSinceNow:20] duration:30 * 60.f intensity:LightExercise details:@"Walking"]];

    NSArray *glukitExercises = [ModelConverter convertExercises:exercises];
    NSArray *dictionaries = [MTLJSONAdapter JSONArrayFromModels:glukitExercises];
    NSError *error;
    NSString *json = [JsonEncoder encodeDictionaryArrayToJSON:dictionaries error:&error];

    if (error == nil) {
        NSLog(@"Exercises are %@", json);
    } else {
        XCTFail(@"Error encoding: %@", error);
    }
}

@end
