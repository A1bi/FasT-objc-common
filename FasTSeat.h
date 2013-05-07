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
    NSInteger posX, posY;
    BOOL reserved, selected;
}

@property (nonatomic, readonly) NSString *seatId;
@property (nonatomic, readonly) NSInteger posX, posY;
@property (nonatomic, readonly) BOOL reserved, selected;

- (id)initWithId:(NSString *)sId andInfo:(NSDictionary *)info;
- (void)updateWithInfo:(NSDictionary *)info;

@end
