#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DDYHeartBeatType) {
    DDYHeartBeatTypeRefresh = 0,
    DDYHeartBeatTypeTranslation = 1,
};

@interface DDYHeartBeat : UIView

+ (instancetype)heartBeatViewWithMaxPointCount:(NSUInteger)maxCount type:(DDYHeartBeatType)type;

- (void)addData:(NSString *)data;

@end

/**
 本demo目前针对规律心跳，所有不可根据最大值最小值进行缩放(过大或过小会绘制到画布外)，不可看历史记录
 
 如若用在其他，可看下面:
 1.增加添加旧数据点的方法，这样实现看历史数据
 2.更加数据进行比例分配，比如原来minY=-10，maxY=10；现在突然开始数据波动更大，minY=-100,maxY=100;
 那么已经有的那些点等比缩放。
 3.如果想单纯一个心跳动图，可以固定数据循环，当然也可以直接使用 DDYHeatBeatAnimation
 */
