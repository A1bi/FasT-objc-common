//
//  FasTFormatter.h
//  FasT-retail
//
//  Created by Albrecht Oster on 28.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTFormatter : NSObject

+ (NSString *)stringForEventDate:(NSDate *)date;
+ (NSString *)stringForPrice:(float)price;

@end
