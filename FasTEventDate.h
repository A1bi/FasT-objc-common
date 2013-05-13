//
//  FasTEventDate.h
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FasTEvent;

@interface FasTEventDate : NSObject
{
    NSDate *date;
    NSString *dateId;
    FasTEvent *event;
}

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *dateId;
@property (nonatomic, readonly) FasTEvent *event;

- (id)initWithInfo:(NSDictionary *)info event:(FasTEvent *)event;

- (NSString *)localizedString;

@end
