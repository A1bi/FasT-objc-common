@class PKPrintSettings;

@interface PKPrinter : NSObject

+ (id)nameForHardcodedURI:(id)arg1;
+ (id)hardcodedURIs;
+ (BOOL)printerLookupWithName:(id)arg1 andTimeout:(double)arg2;
+ (id)printerWithName:(id)arg1;
+ (id)requiredPDL;
+ (BOOL)urfIsOptional;
+ (struct _ipp_s *)getAttributes:(const char **)arg1 count:(int)arg2 fromURI:(id)arg3;
@property(readonly) BOOL hasIdentifyPrinterOp;
@property BOOL isLocal;
@property(readonly) int accessState;
@property(readonly) int type;
@property(readonly) int kind;
@property(readonly) NSString *name;
- (void)reconfirmWithForce:(BOOL)arg1;
- (void)cancelUnlock;
- (void)unlockWithCompletionHandler:(id)arg1;
- (id)matchedPaper:(id)arg1 preferBorderless:(BOOL)arg2 withDuplexMode:(id)arg3 didMatch:(char *)arg4;
- (int)startJob:(id)arg1 ofType:(id)arg2;
- (int)sendData:(const char *)arg1 ofLength:(int)arg2;
- (int)printURL:(NSURL *)url ofType:(NSString *)type printSettings:(PKPrintSettings *)printSettings;
- (int)finishJob;
- (int)abortJob;
- (id)paperListForDuplexMode:(id)arg1;
@property(readonly) NSString *uuid;
@property(readonly) BOOL isIPPS;
@property(readonly) BOOL isAdobeRGBSupported;
@property(readonly) NSDictionary *printInfoSupported;
- (void)checkOperations:(struct _ipp_s *)arg1;
- (void)identifySelf;
@property(readonly) BOOL hasPrintInfoSupported;
- (BOOL)knowsReadyPaperList;
- (BOOL)isPaperReady:(id)arg1;
- (int)feedOrientation:(id)arg1;
- (void)aggdAppsAndPrinters;
- (id)location;
- (id)displayName;
- (BOOL)isBonjour;
- (void)setPrivateObject:(id)arg1 forKey:(id)arg2;
- (id)privateObjectForKey:(id)arg1;
- (id)localName;
- (int)finalizeJob:(int)arg1;
- (struct _ipp_s *)createRequest:(id)arg1 ofType:(id)arg2 url:(id)arg3;
- (struct _ipp_s *)newMediaColFromPaper:(id)arg1 Source:(id)arg2 Type:(id)arg3 DoMargins:(BOOL)arg4;
- (BOOL)resolveWithTimeout:(int)arg1;
- (void)resolve;
@property(readonly) NSString *scheme;
@property(retain) NSNumber *port;
@property(retain) NSString *hostname;
@property(retain) NSDictionary *TXTRecord;
- (void)setAccessStateFromTXT:(id)arg1;
- (void)updateType;
- (id)initWithName:(id)arg1 TXTRecord:(id)arg2;
- (id)initWithName:(id)arg1 TXT:(id)arg2;
- (struct _ipp_s *)getPrinterAttributes;

@end

