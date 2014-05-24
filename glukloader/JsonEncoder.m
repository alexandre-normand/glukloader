#import "JsonEncoder.h"


@implementation JsonEncoder {

}
+ (NSString *)encodeDictionaryArrayToJSON:(NSArray *)dictionaries error:(NSError **)error {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionaries
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];

    if (*error == nil) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    } else {
        return nil;
    }
}

@end