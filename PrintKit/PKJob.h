@class PKPrintSettings;

@interface PKJob : NSObject

+ (id)jobs;
+ (id)currentJob;
@property(retain, nonatomic) NSData *thumbnailImage;
@property(retain, nonatomic) NSDate *timeAtProcessing;
@property(retain, nonatomic) NSDate *timeAtCreation;
@property(retain, nonatomic) NSDate *timeAtCompleted;
@property(nonatomic) int state;
@property(retain, nonatomic) PKPrintSettings *settings;
@property(retain, nonatomic) NSString *printerLocation;
@property(nonatomic) int printerKind;
@property(retain, nonatomic) NSString *printerDisplayName;
@property(nonatomic) int mediaSheetsCompleted;
@property(nonatomic) int mediaSheets;
@property(nonatomic) int mediaProgress;
@property(nonatomic) int number;
- (int)update;
- (int)cancel;

@end

