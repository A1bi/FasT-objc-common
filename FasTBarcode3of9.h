//
//  FasTBarcode3of9.h
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 15.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FasTBarcode3of9 : NSObject

+ (void)drawInRect:(CGRect)rect withContent:(NSString *)content;

@end
