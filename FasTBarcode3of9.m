//
//  FasTBarcode3of9.m
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 15.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTBarcode3of9.h"

#define kFasTBarcode3of9CharCount 14

static const unsigned char FasTBarcode3of9Chars[kFasTBarcode3of9CharCount] = "0123456789TOM*";

typedef struct {
    unsigned int bars, spaces;
} FasTBarcode3of9Encoding;

static const FasTBarcode3of9Encoding FasTBarcode3of9Encodings[kFasTBarcode3of9CharCount] = {
    { 0x6,  0x4 }, // 0
    { 0x11, 0x4 },
    { 0x9,  0x4 },
    { 0x18, 0x4 },
    { 0x5,  0x4 },
    { 0x14, 0x4 },
    { 0xC,  0x4 },
    { 0x3,  0x4 },
    { 0x12, 0x4 },
    { 0xA,  0x4 }, // 9
    { 0x6,  0x1 }, // T
    { 0x14, 0x1 }, // O
    { 0x18, 0x1 }, // M
    { 0x6,  0x8 }  // *
};

@implementation FasTBarcode3of9

+ (void)drawInRect:(CGRect)rect withContent:(NSString *)content
{
    content = [NSString stringWithFormat:@"*%@*", content];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat posX = rect.origin.x,
            posY = rect.origin.y,
            barWidthNarrow = rect.size.width / ([content length] * 13 - 1),
            barWidthWide = barWidthNarrow * 2;
    
    unsigned int contentLength = [content length];
    unichar buffer[contentLength + 1];
    [content getCharacters:buffer range:NSMakeRange(0, contentLength)];
    
    for (int contentCharIndex = 0; contentCharIndex < contentLength; ++contentCharIndex) {
        unichar currentChar = buffer[contentCharIndex];
        
        for (int barcodeCharIndex = 0; barcodeCharIndex < kFasTBarcode3of9CharCount; barcodeCharIndex++) {
            if (FasTBarcode3of9Chars[barcodeCharIndex] == currentChar) {
                const FasTBarcode3of9Encoding *encoding = &FasTBarcode3of9Encodings[barcodeCharIndex];
                
                for (int bit = 0; bit < 5; bit++) {
                    int actualBit = (4 - bit);
                    bool wideBar = encoding->bars & 1 << actualBit;
                    
                    CGFloat currentBarWidth = (wideBar) ? barWidthWide : barWidthNarrow;
                    CGRect barRect = CGRectMake(posX, posY, currentBarWidth, rect.size.height);
                    CGContextFillRect(context, barRect);
                    posX += currentBarWidth;
                    
                    if (bit < 4) {
                        bool wideBar = encoding->spaces & 1 << --actualBit;
                        posX += (wideBar) ? barWidthWide : barWidthNarrow;
                    }
                }
                
                posX += barWidthNarrow;
            }
        }
        
    }
}

@end
