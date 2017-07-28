//
//  TNRadarView.m
//  TNMapDemo
//
//  Created by chenyn on 2017/7/27.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import "TNRadarView.h"
#import <CoreMotion/CoreMotion.h>

@interface TNRadarView()

@property (nonatomic, strong) UIImageView *radarBackImgView;
@property (nonatomic, strong) UIImageView *radarImgView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

#define DEGREES(d) 180 / M_PI * d
@implementation TNRadarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _radarBackImgView = [[UIImageView alloc] initWithFrame:CGRectMake(.0f, .0f, frame.size.width, frame.size.height)];
        _radarBackImgView.image = [UIImage imageNamed:@"canvas1.png"];
        [self addSubview:_radarBackImgView];
        
        _radarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(.0f, .0f, frame.size.width, frame.size.height)];
        _radarImgView.image = [UIImage imageNamed:@"canvas2.png"];
        [self addSubview:_radarImgView];
        
        [self configCoreMotionManager];
    }
    return self;
}

- (void)configCoreMotionManager
{
    //初始化全局管理对象
    self.motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //判断陀螺仪可不可以，判断陀螺仪是不是开启
    if ([self.motionManager isGyroAvailable]){
        
        //告诉manager，更新频率是100Hz
        self.motionManager.gyroUpdateInterval = 1;
        //Push方式获取和处理数据
        __weak typeof(self) weafSelf = self;
        [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [weafSelf updateRadarStatuWithDeviceMotion:motion];
        }];
    }
}

- (void)updateRadarStatuWithDeviceMotion:(CMDeviceMotion *)motion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 重力在y轴上分量最大，说明设备越接近竖直状态

        CMQuaternion quat = motion.attitude.quaternion;
//        NSLog(@"roll角度：%.4f, pitch角度：%.4f, yaw角度：%.4f", DEGREES(motion.attitude.roll), DEGREES(motion.attitude.pitch), DEGREES(motion.attitude.yaw));
//    
//        NSLog(@"%.4f, %.4f, %.4f %.4f", DEGREES(motion.attitude.quaternion.x), DEGREES(motion.attitude.quaternion.y), DEGREES(motion.attitude.quaternion.z), DEGREES(motion.attitude.quaternion.w));
        
        double x = (quat.x * quat.y + quat.w * quat.z);
        double myYaw = 2 * x * M_PI;
        
        double ysqr = quat.y * quat.y;
        double t3 = 2.0 * (quat.w * quat.z + quat.x * quat.y);
        double t4 = 1.0 - 2.0 * (ysqr + quat.z * quat.z);
        double yaw = atan2(t3, t4);
//        double myYaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
        
        NSLog(@"%.4f  %.4f", x, yaw);
        // yaw角度为零的时候，就是出生点位置
        self.radarBackImgView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.radarBackImgView.transform = CGAffineTransformMakeRotation(yaw);
    });
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
