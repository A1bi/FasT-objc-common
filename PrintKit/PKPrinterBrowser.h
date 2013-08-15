@class PKPrinter;

@protocol PKPrinterBrowserDelegate
- (void)removePrinter:(PKPrinter *)printer moreGoing:(BOOL)moreGoing;
- (void)addPrinter:(PKPrinter *)printer moreComing:(BOOL)moreComing;
@end

@interface PKPrinterBrowser : NSObject

+ (id)browserWithDelegate:(id)arg1;
@property(retain, nonatomic) NSMutableDictionary *printersByUUID;
@property(retain, nonatomic) NSMutableArray *pendingList;
@property(readonly, nonatomic) NSObject<OS_dispatch_queue> *printersQueue;
@property(retain, nonatomic) NSMutableDictionary *printers;
@property(retain, nonatomic) NSFileHandle *handle;
@property(nonatomic, assign) id <PKPrinterBrowserDelegate> delegate;
- (void)queryHardcodedPrinters;
- (void)queryCallback:(int)arg1 flags:(unsigned int)arg2 fullName:(const char *)arg3 rdlen:(unsigned short)arg4 rdata:(const void *)arg5;
- (void)browseLocalCallback:(unsigned int)arg1 interface:(unsigned int)arg2 name:(const char *)arg3 regType:(const char *)arg4 domain:(const char *)arg5;
- (void)browseCallback:(unsigned int)arg1 interface:(unsigned int)arg2 name:(const char *)arg3 regType:(const char *)arg4 domain:(const char *)arg5;
- (void)addBlockToPendingList:(id)arg1;
- (void)addQueryResult:(id)arg1 toPrinter:(id)arg2;
- (void)reissueTXTQuery:(id)arg1;
- (void)addLimboPrinter:(id)arg1 local:(BOOL)arg2;
- (void)removePrinter:(id)arg1;
- (id)initWithDelegate:(id)arg1;

@end

