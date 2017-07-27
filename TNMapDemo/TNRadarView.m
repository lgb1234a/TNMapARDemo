//
//  TNRadarView.m
//  TNMapDemo
//
//  Created by chenyn on 2017/7/27.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import "TNRadarView.h"
#import "ARPlayViewController.h"

@interface TNRadarView() <ARPlayViewControllerDelegate>

@property (nonatomic, strong) UIImageView *radarBackImgView;
@property (nonatomic, strong) UIView *dotView;

@end

@implementation TNRadarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _radarBackImgView = [[UIImageView alloc] initWithFrame:CGRectMake(.0f, .0f, frame.size.width, frame.size.height)];
        _radarBackImgView.image = [UIImage imageNamed:@"radarBackImg.png"];
        [self addSubview:_radarBackImgView];
        
        _dotView = [[UIView alloc] initWithFrame:CGRectMake(31.0f, 15.0f, 2.0f, 2.0f)];
        _dotView.layer.cornerRadius = 1.0f;
        _dotView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_dotView];
    }
    return self;
}

- (void)updateRadarStatuWithDeviceMotion:(CMDeviceMotion *)motion
{
    //获取这个然后使用这个角度进行view旋转，可以实现view保持水平的效果，设置一个图片可以测试
    double rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI;
    //            weakSelf.arImageView.transform = CGAffineTransformMakeRotation(rotation);
    
    //2. Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
    double gravityX = motion.gravity.x;
    double gravityY = motion.gravity.y;
    double gravityZ = motion.gravity.z;
    
    //获取手机的倾斜角度(zTheta是手机与水平面的夹角， xyTheta是手机绕自身旋转的角度)：
    double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
    double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;
    
    NSLog(@"水平倾角：%.4f，旋转角度：%.4f", zTheta, xyTheta);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
