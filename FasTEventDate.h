//
//  FasTEventDate.h
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTEventDate : NSObject
{
    NSDate *date;
    NSString *dateId;
}

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *dateId;

- (id)initWithInfo:(NSDictionary *)info;

- (NSString *)localizedString;

@end
