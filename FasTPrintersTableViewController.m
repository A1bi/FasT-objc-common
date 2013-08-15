//
//  FasTPrintersTableViewController.m
//  FasT-retail-checkout
//
//  Created by Albrecht Oster on 15.05.13.
//  Copyright (c) 2013 Albisigns. All rights reserved.
//

#import "FasTPrintersTableViewController.h"
#import "FasTConstants.h"
#import "PKPrinter.h"

@interface FasTPrintersTableViewController ()

@end

@implementation FasTPrintersTableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        foundPrinters = [[NSMutableArray alloc] init];
        printerBrowser = [[PKPrinterBrowser alloc] initWithDelegate:self];
        currentPrinterName = [[[NSUserDefaults standardUserDefaults] objectForKey:FasTPrinterNamePrefKey] retain];
        
        [self setTitle:NSLocalizedStringByKey(@"selectPrinter")];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [foundPrinters release];
    [printerBrowser release];
    [currentPrinterName release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [foundPrinters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKPrinter *printer = foundPrinters[[indexPath row]];
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    [[cell textLabel] setText:[printer description]];
    [[cell detailTextLabel] setText:[printer TXTRecord][@"ty"]];
    if ([currentPrinterName isEqualToString:[printer name]]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKPrinter *printer = foundPrinters[[indexPath row]];
    NSDictionary *prefs = @{FasTPrinterNamePrefKey: [printer name], FasTPrinterDescriptionPrefKey: [printer description]};
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:prefs];
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - printer browser delegate

- (void)addPrinter:(PKPrinter *)printer moreComing:(BOOL)moreComing
{
    [foundPrinters addObject:printer];
    if (!moreComing) [[self tableView] reloadData];
}

- (void)removePrinter:(PKPrinter *)printer moreGoing:(BOOL)moreGoing
{
    [foundPrinters removeObject:printer];
    if (!moreGoing) [[self tableView] reloadData];
}

@end
