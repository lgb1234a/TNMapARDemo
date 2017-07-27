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

@interface ARPlayViewController ()

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

@end
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation ARPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initAVCaptureSession];
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

- (void)addSwitchButton
{
    _bView = [UIView new];
    
    UISwitch *switchBtn = [[UISwitch alloc] init];
    switchBtn.frame = CGRectMake(kMainScreenWidth - 60, kMainScreenHeight - 60, 60, 30);
    [switchBtn setOn:YES];
    
    [switchBtn addTarget:self action:@selector(changeCameraStatus:) forControlEvents:UIControlEventTouchUpInside];
    [_bView addSubview:switchBtn];
    
    _bView.backgroundColor = [UIColor clearColor];
    _bView.frame = self.view.bounds;
    [self.view addSubview:_bView];
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
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

@end
