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

@end
