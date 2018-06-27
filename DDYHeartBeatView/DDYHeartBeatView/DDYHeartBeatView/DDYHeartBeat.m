#import "DDYHeartBeat.h"

#define frameH self.frame.size.height
#define frameW self.frame.size.width

static CGFloat kLineWidth = 1.f;
static inline UIColor *lineColor(void) { return [UIColor greenColor]; }

@interface DDYHeartBeat ()
/** 同时同屏最多绘制点的数量（越大越密集） 默认300 最好别低于100 */
@property (nonatomic, assign) NSUInteger maxCount;
/** 加载方式 */
@property (nonatomic, assign) DDYHeartBeatType type;
/** 保存dataY */
@property (nonatomic, strong) NSMutableArray *dataYArray;
/** 保存点的数组 */
@property (nonatomic, strong) NSMutableArray *pointArray;

@end

@implementation DDYHeartBeat

+ (instancetype)heartBeatViewWithMaxPointCount:(NSUInteger)maxCount type:(DDYHeartBeatType)type {
    return [[self alloc] initWithMaxPointCount:maxCount type:type];
}

- (instancetype)initWithMaxPointCount:(NSUInteger)maxCount type:(DDYHeartBeatType)type {
    if (self = [super init]) {
        _maxCount = MAX(maxCount, 50);
        _dataYArray = [NSMutableArray arrayWithCapacity:maxCount];
        _pointArray = [NSMutableArray arrayWithCapacity:maxCount];
        _type = type;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _maxCount = MIN(frame.size.width, _maxCount);
}

- (void)addData:(NSString *)data {
    if (![self ddy_Validity:data]) return;
    
    if (self.type == DDYHeartBeatTypeRefresh) {
        [self handleRefreshTypeData:data];
    } else if (self.type == DDYHeartBeatTypeTranslation) {
        [self handleTranslationTypeData:data];
    }
    [self setNeedsDisplay];
}

#pragma mark 数据是否合法(整数或浮点数)
- (BOOL)ddy_Validity:(NSString *)str {
    // 不为空
    if (str == nil || str == NULL || [str isEqualToString:@"(null)"] || [str isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return NO;
    }
    // 只能含数字和小数点及负号
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-."] invertedSet];
    if (![str isEqualToString:[[str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""]]) {
        return NO;
    }
    // 正则匹配整数或浮点数 0.0合法 0.00000不合法
    NSString *regex = @"^-?([1-9]d*|[1-9]d*.d*|0.d*[1-9]d*|0?.0+|0)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:str];
}

- (void)handleRefreshTypeData:(NSString *)data {
    static NSInteger index = -1;
    index ++;
    index %= (int)frameW;
    
    if (self.pointArray.count >= self.maxCount) [self.pointArray removeObjectAtIndex:0];
    [self.pointArray addObject:@{@"x":@(index), @"y":data}];
}

- (void)handleTranslationTypeData:(NSString *)data {
    if (self.dataYArray.count  >= frameW) [self.dataYArray removeLastObject];
    [self.dataYArray insertObject:data atIndex:0];
}

#pragma mark 绘制背景坐标格
- (void)drawBackGrid:(CGContextRef)ctx {
    // 小格子
    CGFloat smallCellW = 5;
    CGFloat smallCellX = 0.0;
    CGFloat smallCellY = 0.0;
    CGContextSetLineWidth(ctx, 0.1);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    // 小格子横线
    while (smallCellY <= frameH) {
        CGContextMoveToPoint(ctx, 1, smallCellY);
        CGContextAddLineToPoint(ctx, frameW, smallCellY);
        smallCellY += smallCellW;
    }
    // 小格子纵线
    while (smallCellX < frameW) {
        CGContextMoveToPoint(ctx, smallCellX, 1);
        CGContextAddLineToPoint(ctx, smallCellX, frameH);
        smallCellX += smallCellW;
    }
    CGContextStrokePath(ctx);
    
    /** 大格子 */
    CGFloat bigCellW = smallCellW * 5;
    CGFloat bigCellX = 0.0;
    CGFloat bigCellY = 0.0;
    CGContextSetLineWidth(ctx, 0.2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    // 大格子横线
    while (bigCellY <= frameH) {
        CGContextMoveToPoint(ctx, 1, bigCellY);
        CGContextAddLineToPoint(ctx, frameW, bigCellY);
        bigCellY += bigCellW;
    }
    // 大格子纵线
    while (bigCellX < frameW) {
        CGContextMoveToPoint(ctx, bigCellX, 1);
        CGContextAddLineToPoint(ctx, bigCellX, frameH);
        bigCellX += bigCellW;
    }
    CGContextStrokePath(ctx);
}

#pragma mark 绘制前景心跳线
- (void)drawForeBeat:(CGContextRef)ctx {
    // 坐标转换
    CGContextTranslateCTM(ctx, 0, frameH/2.);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextSetLineWidth(ctx, kLineWidth);
    CGContextSetStrokeColorWithColor(ctx, lineColor().CGColor);
    if (self.type == DDYHeartBeatTypeRefresh) {
        if (self.pointArray.count == 0) return;
        CGContextMoveToPoint(ctx, [self.pointArray[0][@"x"] floatValue], [self.pointArray[0][@"y"] floatValue]);
        for (int i = 1; i < _pointArray.count; i++) {
            if ([self.pointArray[i][@"x"] floatValue] > [self.pointArray[i-1][@"x"] floatValue]) {
                CGContextAddLineToPoint(ctx, [self.pointArray[i][@"x"] floatValue], [self.pointArray[i][@"y"] floatValue]);
            } else {
                CGContextMoveToPoint(ctx, [self.pointArray[i][@"x"] floatValue], [self.pointArray[i][@"y"] floatValue]);
            }
        }
    } else if (self.type == DDYHeartBeatTypeTranslation) {
        for (int i = 0; i < self.dataYArray.count; i++) {
            if (i == 0) {
                CGContextMoveToPoint(ctx, 0, [self.dataYArray[0] floatValue]);
            } else {
                CGContextAddLineToPoint(ctx, i, [self.dataYArray[i] floatValue]);
            }
        }
    }
    CGContextStrokePath(ctx);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 绘制
    [self drawBackGrid:ctx];
    [self drawForeBeat:ctx];
}


@end
