//
//  FasTSeat.h
//  FasT-retail
//
//  Created by Albrecht Oster on 29.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTSeat : NSObject
{
    NSString *seatId;
    NSString *number, *row, *blockName;
    NSInteger posX, posY;
    BOOL reserved, selected;
}

@property (nonatomic, readonly) NSString *seatId;
@property (nonatomic, readonly) NSString *number, *row, *blockName;
@property (nonatomic, readonly) NSInteger posX, posY;
@property (nonatomic, readonly) BOOL reserved, selected;

- (id)initWithInfo:(NSDictionary *)info reserved:(BOOL)reserved;
- (void)updateWithInfo:(NSDictionary *)info;

@end
