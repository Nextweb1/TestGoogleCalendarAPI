//
//  GCAEventResponse.h
//  GoogleCalendarApi
//
//  Created by Murali on 18/07/18.
//

#import <Foundation/Foundation.h>

@interface GCAEventsSearchResponse : NSObject

@property (nonatomic, strong, readonly) NSArray *events;

- (instancetype)initWithParsedData:(NSDictionary *)parsedData;

@end
