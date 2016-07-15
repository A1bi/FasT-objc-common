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

#define kPointsToMillimeters(points) (points * 35.28)
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
        [self initPrinter];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPrinter) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [printer release];
    [super dealloc];
}

- (void)initPrinter
{
    NSString *printerUrl = [[NSUserDefaults standardUserDefaults] objectForKey:FasTTicketPrinterUrlPrefKey];
    if (printerUrl && (!printer || ![printer.URL.absoluteString isEqualToString:printerUrl])) {
        [printer release];
        printer = [[UIPrinter printerWithURL:[NSURL URLWithString:printerUrl]] retain];
        [printer contactPrinter:NULL];
    }
}

- (void)printTickets:(NSArray *)tickets
{
    if (!printer || tickets.count < 1) return;
    
    [[FasTApi defaultApi] fetchPrintableForTickets:tickets callback:^(NSData *data) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
        
            NSString *ticketsPath = [[NSString stringWithFormat:@"%@tickets.pdf", NSTemporaryDirectory()] retain];

            [data writeToFile:ticketsPath atomically:YES];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
#pragma clang diagnostic ignored "-Wundeclared-selector"
            
//            CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:ticketsPath];
//            CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(url);
//            CGPDFPageRef firstPage = CGPDFDocumentGetPage(document, 1);
//            CGSize pageSize = CGPDFPageGetBoxRect(firstPage, kCGPDFMediaBox).size;
//            CGPDFDocumentRelease(document);
            
            Class PKPaper = NSClassFromString(@"PKPaper");
            id paper = [PKPaper genericA4Paper];
            [paper setTopMargin:0];
            [paper setRightMargin:0];
            [paper setBottomMargin:0];
            [paper setLeftMargin:0];
//            [paper setWidth:kPointsToMillimeters(pageSize.height)];
//            [paper setHeight:kPointsToMillimeters(pageSize.width)];
            
            Class PKPrintSettings = NSClassFromString(@"PKPrintSettings");
            id settings = [PKPrintSettings default];
            [settings setPaper:paper];
            
            id p = [printer performSelector:@selector(_internalPrinter)];
            [p printURL:[NSURL fileURLWithPath:ticketsPath] ofType:@"application/pdf" printSettings:settings];
            
            [[NSFileManager defaultManager] removeItemAtPath:ticketsPath error:nil];
#pragma clang diagnostic pop
#pragma clang diagnostic pop
        });
    }];
}

@end
