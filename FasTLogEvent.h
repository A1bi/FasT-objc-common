//
//  FasTLogEvent.h
//  FasT-box-office
//
//  Created by Albrecht Oster on 21.07.14.
//  Copyright (c) 2014 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTLogEvent : NSObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *message;

- (id)initWithInfo:(NSDictionary *)info;

@end
