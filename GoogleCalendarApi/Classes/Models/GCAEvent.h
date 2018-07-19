//
//  GCAEvent.h
//  GoogleCalendarApi
//
//  Created by Murali on 18/07/18.
//

#import <Foundation/Foundation.h>

@interface GCAEvent : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign, getter=isAdded) BOOL added;

@end
