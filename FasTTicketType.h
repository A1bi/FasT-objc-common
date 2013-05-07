//
//  FasTTicketType.h
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTTicketType : NSObject
{
    float price;
    NSString *name, *info;
    NSString *typeId;
}

@property (nonatomic, readonly) NSString *name, *info, *typeId;
@property (nonatomic, readonly) float price;

- (id)initWithInfo:(NSDictionary *)info;

- (NSString *)localizedPrice;

@end
