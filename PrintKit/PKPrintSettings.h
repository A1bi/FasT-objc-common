@class PKPaper;

@interface PKPrintSettings : NSObject

+ (id)printSettingsForPrinter:(id)arg1;
+ (id)photo;
+ (id)default;
@property(retain, nonatomic) PKPaper *paper;
@property(retain, nonatomic) NSMutableDictionary *dict;
- (id)objectForKey:(id)arg1;
- (void)removeObjectForKey:(id)arg1;
- (void)setObject:(id)arg1 forKey:(id)arg2;
- (id)settingsDict;

@end

