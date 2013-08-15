@interface PKPaper : NSObject

+ (id)documentPapers;
+ (id)photoPapers;
+ (BOOL)willAdjustMarginsForDuplexMode:(id)arg1;
+ (id)genericBorderlessWithName:(id)arg1;
+ (id)genericWithName:(id)arg1;
+ (id)genericPRC32KPaper;
+ (id)genericHagakiPaper;
+ (id)genericA6Paper;
+ (id)generic4x6Paper;
+ (id)generic3_5x5Paper;
+ (id)genericLetterPaper;
+ (id)genericA4Paper;
@property(nonatomic) int bottomMargin;
@property(nonatomic) int rightMargin;
@property(nonatomic) int topMargin;
@property(nonatomic) int leftMargin;
@property(nonatomic) int height;
@property(nonatomic) int width;
@property(retain, nonatomic) NSString *name;
- (unsigned int)hash;
- (BOOL)isEqual:(id)arg1;
- (id)paperWithMarginsAdjustedForDuplexMode:(id)arg1;
@property(readonly, nonatomic) NSString *localizedName;
- (id)localizedNameFromDimensions;
@property(readonly, nonatomic) NSString *baseName;
- (id)nameWithoutSuffixes:(id)arg1;
@property(readonly, nonatomic) BOOL isBorderless;
@property(readonly, nonatomic) float imageableArea;
@property(readonly, nonatomic) struct CGRect imageableAreaRect;
@property(readonly, nonatomic) struct CGSize paperSize;
- (id)initWithWidth:(int)arg1 Height:(int)arg2 Left:(int)arg3 Top:(int)arg4 Right:(int)arg5 Bottom:(int)arg6 localizedName:(id)arg7 codeName:(id)arg8;

@end

