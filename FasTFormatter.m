//
//  FasTFormatter.m
//  FasT-retail
//
//  Created by Albrecht Oster on 28.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTFormatter.h"

static NSDateFormatter *dateFormatter;
static NSNumberFormatter *numberFormatter;

@implementation FasTFormatter

+ (NSString *)stringForEventDate:(NSDate *)date
{
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:NSLocalizedStringByKey(@"eventDateFormat")];
    }
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringForPrice:(float)price
{
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setCurrencySymbol:@"€"];
    }
    
    return [numberFormatter stringFromNumber:@(price)];
}

@end
