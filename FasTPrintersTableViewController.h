//
//  FasTPrintersTableViewController.h
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 15.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKPrinterBrowser.h"

@interface FasTPrintersTableViewController : UITableViewController <PKPrinterBrowserDelegate>
{
    NSMutableArray *foundPrinters;
    PKPrinterBrowser *printerBrowser;
    NSString *currentPrinterName;
}

@end
