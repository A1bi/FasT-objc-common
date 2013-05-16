//
//  FasTTicketPrinter.m
//  FasT-retail
//
//  Created by Albrecht Oster on 27.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTTicketPrinter.h"
#import "FasTEvent.h"
#import "FasTEventDate.h"
#import "FasTTicketType.h"
#import "FasTOrder.h"
#import "FasTTicket.h"
#import "FasTSeat.h"
#import "FasTBarcode3of9.h"
#import "PKPrinter.h"
#import "PKPrintSettings.h"
#import "PKPaper.h"

#define kPointsToMilimetersFactor 35.28
static const double kRotationRadians = -90 * M_PI / 180;
static FasTTicketPrinter *sharedPrinter = nil;

@interface FasTTicketPrinter ()

- (void)initPrinter;
- (void)generatePDFWithOrder:(FasTOrder *)order;
- (void)generateTicket:(FasTTicket *)ticket;
- (void)drawBarcodeForTicket:(FasTTicket *)ticket;
- (void)drawLogo;
- (void)drawEventInfoForDate:(FasTEventDate *)date;
- (void)drawSeatInfo:(FasTSeat *)seat;
- (void)drawTicketTypeInfo:(FasTTicketType *)type;
- (void)drawBottomInfoForTicket:(FasTTicket *)ticket;
- (void)drawSeparatorWithSize:(CGSize)size;
- (CGSize)drawText:(NSString *)text withFont:(UIFont *)font;
- (CGSize)drawText:(NSString *)text withFontSize:(NSString *)size;
- (CGSize)drawText:(NSString *)text withFontSize:(NSString *)size andIncreaseY:(BOOL)incY;
- (void)drawHorizontalArrayOfTexts:(NSArray *)texts withFontSize:(NSString *)fontSize margin:(CGFloat)margin;
- (NSArray *)arrayOfStrings:(NSArray *)strings withLocalizedCaptionsFromKeys:(NSArray *)keys;

@end

@implementation FasTTicketPrinter

+ (FasTTicketPrinter *)sharedPrinter
{
    if (!sharedPrinter) {
        sharedPrinter = [[super allocWithZone:NULL] init];
    }
    return sharedPrinter;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedPrinter] retain];
}

- (id)init
{
    self = [super init];
    if (self) {
        ticketWidth = 595, ticketHeight = 240;
        
        NSString *fontName = @"Avenir";
        NSMutableDictionary *tmpFonts = [NSMutableDictionary dictionary];
        NSDictionary *fontSizes = @{@"normal": @(16), @"small": @(13), @"tiny": @(11)};
        for (NSString *fontSize in fontSizes) {
            tmpFonts[fontSize] = [UIFont fontWithName:fontName size:[fontSizes[fontSize] floatValue]];
        }
        fonts = [[NSDictionary dictionaryWithDictionary:tmpFonts] retain];
        
        ticketsPath = [[NSString stringWithFormat:@"%@tickets.pdf", NSTemporaryDirectory()] retain];
        
        PKPaper *ticketPaper = [[[PKPaper alloc] initWithWidth:ticketHeight * kPointsToMilimetersFactor Height:ticketWidth * kPointsToMilimetersFactor + 450 Left:0 Top:0 Right:0 Bottom:0 localizedName:nil codeName:nil] autorelease];
        printSettings = [[PKPrintSettings default] retain];
        [printSettings setPaper:ticketPaper];
        
        [self initPrinter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPrinter) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [fonts release];
    [ticketsPath release];
    [printSettings release];
    [printer release];
    [super dealloc];
}

- (void)initPrinter
{
    NSString *printerName = [[NSUserDefaults standardUserDefaults] objectForKey:FasTPrinterNamePrefKey];
    if (printerName && (!printer || ![[printer name] isEqualToString:printerName])) {
        [printer release];
        printer = [[PKPrinter printerWithName:printerName] retain];
    }
}

- (void)printTicketsForOrder:(FasTOrder *)order
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        if (!printer) return;
        
        [self generatePDFWithOrder:order];
        
        [printer printURL:[NSURL fileURLWithPath:ticketsPath] ofType:@"application/pdf" printSettings:printSettings];
        
        [[NSFileManager defaultManager] removeItemAtPath:ticketsPath error:nil];
        
    });
}

- (void)generatePDFWithOrder:(FasTOrder *)order
{
    UIGraphicsBeginPDFContextToFile(ticketsPath, CGRectMake(0, 0, ticketHeight, ticketWidth), nil);
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    for (FasTTicket *ticket in [order tickets]) {
        [self generateTicket:ticket];
    }
    
    UIGraphicsEndPDFContext();
}

- (void)generateTicket:(FasTTicket *)ticket
{
    posX = 0, posY = 0;
    UIGraphicsBeginPDFPage();
    // rotate pdf 90 degrees so the printer can print in portrait mode
    CGContextTranslateCTM(context, 0, ticketWidth);
    CGContextRotateCTM(context, kRotationRadians);
    
    [self drawBarcodeForTicket:ticket];
    [self drawLogo];
    [self drawEventInfoForDate:[ticket date]];
    [self drawSeatInfo:[ticket seat]];
    [self drawTicketTypeInfo:[ticket type]];
    [self drawBottomInfoForTicket:ticket];
}

- (void)drawBarcodeForTicket:(FasTTicket *)ticket
{
    CGFloat margin = 10,
            height = 60, width = ticketHeight - margin * 2;
    
    posX = margin;
    posY = margin;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, posX + height + margin, 0);
    CGContextRotateCTM(context, -kRotationRadians);
    
    NSString *content = [NSString stringWithFormat:@"T%@M0", [ticket number]];
    [FasTBarcode3of9 drawInRect:CGRectMake(posX, posY, width, height) withContent:content];
    
    CGContextRestoreGState(context);
    posX = margin + height + margin;
    
    [self drawSeparatorWithSize:CGSizeMake(.5, ticketHeight - posY * 2)];
    posX += 30;
    posY += 4;
}

- (void)drawLogo
{
    UIImage *logo = [UIImage imageNamed:@"logo.png"];
    CGSize size = [logo size];
    CGFloat width = 100, margin = 20;
    CGRect logoRect = CGRectMake(ticketWidth - width - margin, margin, width, size.height / size.width * width);
    [logo drawInRect:logoRect];
}

- (void)drawEventInfoForDate:(FasTEventDate *)date
{
    UIFont *eventTitleFont = [UIFont fontWithName:@"SnellRoundhand" size:40];
    CGSize size = [self drawText:[[date event] name] withFont:eventTitleFont];
    posY += size.height + 5;
    
    [self drawText:[date localizedString] withFontSize:@"normal" andIncreaseY:YES];
    
    [self drawText:@"Einlass ab 19.00 Uhr" withFontSize:@"small" andIncreaseY:YES];
    posY += 10;
    [self drawText:@"Historischer Ortskern, Kaisersesch" withFontSize:@"small" andIncreaseY:YES];
    posY += 30;
}

- (void)drawSeatInfo:(FasTSeat *)seat
{
    NSArray *texts = @[[seat blockName], [seat row], [seat number]];
    NSArray *keys = @[@"block", @"row", @"seat"];
    [self drawHorizontalArrayOfTexts:[self arrayOfStrings:texts withLocalizedCaptionsFromKeys:keys] withFontSize:@"small" margin:8];
    
    posY -= 25;
}

- (void)drawTicketTypeInfo:(FasTTicketType *)type
{
    CGFloat tmpX = posX;
    UIFont *font = fonts[@"normal"];
    
    NSString *printString = [type name];
    CGSize size = [printString sizeWithFont:font];
    posX = ticketWidth - size.width - 50;
    [self drawText:printString withFontSize:@"normal" andIncreaseY:YES];
    
    printString = [type localizedPrice];
    size = [printString sizeWithFont:font];
    posX = ticketWidth - size.width - 50;
    [self drawText:printString withFontSize:@"normal" andIncreaseY:YES];
    posX = tmpX;
    posY += 23;
}

- (void)drawBottomInfoForTicket:(FasTTicket *)ticket
{
    [self drawSeparatorWithSize:CGSizeMake(ticketWidth-posX-40, .5)];
    posY += 4;
    posX += 5;
    
    NSArray *texts = @[[ticket number], [[ticket order] number]];
    NSArray *keys = @[@"ticket", @"order"];
    NSMutableArray *strings = [NSMutableArray arrayWithArray:[self arrayOfStrings:texts withLocalizedCaptionsFromKeys:keys]];
    [strings addObject:NSLocalizedStringByKey(@"websiteUrl")];
    [self drawHorizontalArrayOfTexts:strings withFontSize:@"tiny" margin:15];
}

- (void)drawSeparatorWithSize:(CGSize)size
{
    CGContextFillRect(context, CGRectMake(posX, posY, size.width, size.height));
}

- (CGSize)drawText:(NSString *)text withFont:(UIFont *)font
{
    return [text drawAtPoint:CGPointMake(posX, posY) withFont:font];
}

- (CGSize)drawText:(NSString *)text withFontSize:(NSString *)size
{
    return [self drawText:text withFontSize:size andIncreaseY:-1];
}

- (CGSize)drawText:(NSString *)text withFontSize:(NSString *)size andIncreaseY:(BOOL)incY
{
    UIFont *font = fonts[size];
    [self drawText:text withFont:font];
    
    CGSize textSize = [text sizeWithFont:font];
    if (incY == YES) {
        posY += textSize.height;
    } else if (incY == NO) {
        posX += textSize.width;
    }
    
    return textSize;
}

- (void)drawHorizontalArrayOfTexts:(NSArray *)texts withFontSize:(NSString *)fontSize margin:(CGFloat)margin
{
    CGFloat tmpX = posX;
    CGFloat separatorWidth = .3;
    CGSize size;
    
    int i = 0;
    for (NSString *text in texts) {
        size = [self drawText:text withFontSize:fontSize andIncreaseY:NO];
        
        i++;
        if (i < [texts count]) {
            posX += margin;
            [self drawSeparatorWithSize:CGSizeMake(separatorWidth, size.height)];
            posX += margin + separatorWidth;
        }
    }
    
    posX = tmpX;
}

- (NSArray *)arrayOfStrings:(NSArray *)strings withLocalizedCaptionsFromKeys:(NSArray *)keys
{
    NSMutableArray *array = [NSMutableArray array];
    int i = 0;
    for (NSString *text in strings) {
        [array addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedStringByKey(keys[i]), text]];
        i++;
    }
    return array;
}

@end
