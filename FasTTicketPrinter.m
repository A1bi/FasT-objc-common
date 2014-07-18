//
//  FasTTicketPrinter.m
//  FasT-retail
//
//  Created by Albrecht Oster on 27.04.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTTicketPrinter.h"
#import "FasTApi.h"
#import "FasTOrder.h"
#import "FasTTicket.h"
#import "FasTConstants.h"
#import "PKPrinter.h"
#import "PKPrintSettings.h"
#import "PKPaper.h"

#define kPointsToMilimetersFactor 35.28
static const double kRotationRadians = -90 * M_PI / 180;
static FasTTicketPrinter *sharedPrinter = nil;

@interface FasTTicketPrinter ()

- (void)initPrinter;

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
        ticketsPath = [[NSString stringWithFormat:@"%@tickets.pdf", NSTemporaryDirectory()] retain];
        
        printSettings = [[PKPrintSettings default] retain];
        
        [self initPrinter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPrinter) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ticketsPath release];
    [printSettings release];
    [printer release];
    [super dealloc];
}

- (void)initPrinter
{
    NSString *printerName = [[NSUserDefaults standardUserDefaults] objectForKey:FasTTicketPrinterNamePrefKey];
    if (printerName && (!printer || ![[printer name] isEqualToString:printerName])) {
        [printer release];
        printer = [[PKPrinter printerWithName:printerName] retain];
    }
}

- (void)printTickets:(NSArray *)tickets
{
    if (!printer) return;
    
    [[FasTApi defaultApi] fetchPrintableForTickets:tickets callback:^(NSData *data) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
            [data writeToFile:ticketsPath atomically:YES];
            
            PKPaper *ticketPaper = [[[PKPaper alloc] initWithWidth:280 * kPointsToMilimetersFactor Height:595 * kPointsToMilimetersFactor + 450 Left:0 Top:0 Right:0 Bottom:0 localizedName:nil codeName:nil] autorelease];
            [printSettings setPaper:ticketPaper];
            [printer printURL:[NSURL fileURLWithPath:ticketsPath] ofType:@"application/pdf" printSettings:printSettings];
            
            [[NSFileManager defaultManager] removeItemAtPath:ticketsPath error:nil];
        });
    }];
}

@end
