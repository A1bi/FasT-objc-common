//
//  FasTEvent.h
//  FasT-retail
//
//  Created by Albrecht Oster on 15.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTEvent : NSObject
{
    NSString *name;
    NSArray *dates;
    NSArray *ticketTypes;
    NSMutableDictionary *seats;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *dates;
@property (nonatomic, retain) NSArray *ticketTypes;
@property (nonatomic, readonly) NSMutableDictionary *seats;

- (id)initWithInfo:(NSDictionary *)info;
- (void)updateSeats:(NSDictionary *)seatsInfo;
- (id)objectFromArray:(NSString *)arrayName withId:(NSString *)objId usingIdName:(NSString *)idName;

@end
