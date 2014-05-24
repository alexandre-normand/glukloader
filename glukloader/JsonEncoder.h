#import <Foundation/Foundation.h>


@interface JsonEncoder : NSObject

+ (NSString *)encodeDictionaryArrayToJSON:(NSArray *)array error:(NSError **)error;
@end