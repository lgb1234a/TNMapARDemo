//
//  TNRadarView.h
//  TNMapDemo
//
//  Created by chenyn on 2017/7/27.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMDeviceMotion;
@protocol TNRadarViewDelegate

- (void)updateRadarDataWithDeviceYaw:(double)yaw andRoll:(double)roll;

@end

@interface TNRadarView : UIView

@property (nonatomic, weak) id delegate;

@end
