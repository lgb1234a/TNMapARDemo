//
//  ARPlayViewController.h
//  TNMapDemo
//
//  Created by chenyn on 2017/7/24.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@protocol ARPlayViewControllerDelegate <NSObject>

- (void)updateRadarStatuWithDeviceMotion:(CMDeviceMotion *)motion;

@end

@interface ARPlayViewController : UIViewController

@end
