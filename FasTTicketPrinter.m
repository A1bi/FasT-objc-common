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
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        printController.delegate = self;
        printController.printingItem = data;
        
        [printController printToPrinter:printer completionHandler:NULL];
    }];
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray<UIPrintPaper *> *)paperList {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
#pragma clang diagnostic ignored "-Wundeclared-selector"
//    NSData *data = [printInteractionController _printingItem];
//    CGDataProviderRef dataRef = CGDataProviderCreateWithCFData((CFDataRef)data);
//    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataRef);
//    CGPDFPageRef firstPage = CGPDFDocumentGetPage(document, 1);
//    CGSize pageSize = CGPDFPageGetBoxRect(firstPage, kCGPDFMediaBox).size;
//    CGPDFDocumentRelease(document);
//    
//    int height = ceil(kPointsToMillimeters(pageSize.height));
//    int width = ceil(kPointsToMillimeters(pageSize.width));
    
    Class PKPaper = NSClassFromString(@"PKPaper");
//    id pkPaper = [[[PKPaper alloc] initWithWidth:21000 Height:9900 Left:0 Top:0 Right:0 Bottom:0 localizedName:nil codeName:nil] autorelease];
    id pkPaper = [PKPaper genericA4Paper];
    [pkPaper setTopMargin:0];
    [pkPaper setRightMargin:0];
    [pkPaper setBottomMargin:0];
    [pkPaper setLeftMargin:0];
    
    UIPrintPaper *paper = [[[UIPrintPaper alloc] _initWithPrintKitPaper:pkPaper] autorelease];
    return paper;
#pragma clang diagnostic pop
#pragma clang diagnostic pop
}

@end
