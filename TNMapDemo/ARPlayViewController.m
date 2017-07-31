//
//  ARPlayViewController.m
//  TNMapDemo
//
//  Created by chenyn on 2017/7/24.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import "ARPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TNRadarView.h"

typedef enum : NSUInteger {
    TNOutSideTypeTop = 0,
    TNOutSideTypeLeft,
    TNOutSideTypeBottom,
    TNOutSideTypeRight,
} TNOutSideType;

@interface ARPlayViewController () <TNRadarViewDelegate>

/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic, strong) UIView *bView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) TNRadarView *radarView;
// 用来放置游戏对象的
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIButton *logoBtn;

@end
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height

// 单位角度对应的屏幕宽度+两倍物体宽度
#define kWidthToTheta ([UIScreen mainScreen].bounds.size.width + 640) / M_PI_2
#define kHeightToTheta ([UIScreen mainScreen].bounds.size.height + 400) / M_PI_2

@implementation ARPlayViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initAVCaptureSession];
    [self addBackView];
    [self addScrollView];
    [self addSwitchButton];
    [self addBackButton];
    [self addRadarView];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    [self startCapture];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    [self stopCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI
- (void)addBackView
{
    _bView = [UIView new];
    _bView.backgroundColor = [UIColor clearColor];
    _bView.frame = self.view.bounds;
    [self.view addSubview:_bView];
}

- (void)addSwitchButton
{
    UISwitch *switchBtn = [[UISwitch alloc] init];
    switchBtn.frame = CGRectMake(kMainScreenWidth - 60, kMainScreenHeight - 60, 60, 30);
    [switchBtn setOn:YES];
    
    [switchBtn addTarget:self action:@selector(changeCameraStatus:) forControlEvents:UIControlEventTouchUpInside];
    [_bView addSubview:switchBtn];
}

- (void)addBackButton
{
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(10, 30, 80, 30);
    [_backBtn setTitle:@"<back" forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_bView addSubview:_backBtn];
}

- (void)addRadarView
{
    _radarView = [[TNRadarView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 65, 20, 62, 62)];
    [_bView addSubview:_radarView];
    
    _radarView.delegate = self;
}

- (void)addScrollView
{
    // 当前屏幕角度是90°，所以对应的完整旋转一圈的大小360°的宽度就是4倍的屏幕宽度
    CGFloat wholeWidth = 4 * kMainScreenWidth;
    _backScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _backScrollView.contentSize = CGSizeMake(wholeWidth, 0);
    
    _logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_logoBtn setImage:[UIImage imageNamed:@"testImg.png"] forState:UIControlStateNormal];
    CGFloat originAngle = atan2(16.0f, 9.0f) - M_PI_4;
    _logoBtn.frame = CGRectMake(originAngle * kWidthToTheta + 320, 150, 320, 200);
    
    [_bView addSubview:_backScrollView];
    [_backScrollView addSubview:_logoBtn];
}


#pragma mark - 相机操作
- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
}

// 开关相机
- (void)changeCameraStatus:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    
    if(sw.on)
    {
        [self startCapture];
    }else
    {
        [self stopCapture];
    }
}

- (void)stopCapture
{
    if (self.session) {
        [self.session stopRunning];
        self.bView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)startCapture
{
    if (self.session) {
        [self.session startRunning];
        self.bView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - 模拟AR
// 刷新雷达的检测方位
- (void)updateRadarDataWithDeviceYaw:(double)yaw andRoll:(double)roll
{
    double offsetX = - yaw * kWidthToTheta;
    double offsetY = (M_PI_2 - roll) * kHeightToTheta;
    _backScrollView.contentOffset = CGPointMake(offsetX, offsetY);
    
    CGRect frame = [_logoBtn convertRect:_logoBtn.bounds toView:self.view];
    if(!CGRectIntersectsRect(self.view.bounds, frame))
    {
        // 在屏幕外，提示用户
        switch ([self outSideJudgeWithOutRect:frame toRect:self.view.bounds]) {
            case TNOutSideTypeLeft:
                NSLog(@"请往左侧移动");
                break;
            case TNOutSideTypeRight:
                NSLog(@"请往右侧移动");
                break;
            case TNOutSideTypeTop:
                NSLog(@"请往上方移动");
                break;
            case TNOutSideTypeBottom:
                NSLog(@"请往下方移动");
                break;
                
            default:
                break;
        }
    }
}

// 判断牛牛方位
- (TNOutSideType)outSideJudgeWithOutRect:(CGRect)outSideRect toRect:(CGRect)currentRect
{
    if(CGRectGetMaxX(outSideRect) < CGRectGetMinX(currentRect))
    {
        return TNOutSideTypeLeft;
    }else if (CGRectGetMinX(outSideRect) > CGRectGetMaxX(currentRect))
    {
        return TNOutSideTypeRight;
    }else if (CGRectGetMinY(outSideRect) > CGRectGetMaxY(currentRect))
    {
        return TNOutSideTypeBottom;
    }else if (CGRectGetMaxY(outSideRect) < CGRectGetMinY(currentRect))
    {
        return TNOutSideTypeTop;
    }else
    {
        return -1;
    }
}

@end
