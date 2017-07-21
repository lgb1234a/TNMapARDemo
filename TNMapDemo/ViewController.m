//
//  ViewController.m
//  TNMapDemo
//
//  Created by chenyn on 2017/7/21.
//  Copyright © 2017年 chenyn. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface ViewController () <MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    
    ///把地图添加至view
    [self.view addSubview:_mapView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    [_mapView setZoomLevel:14 animated:YES];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
}

- (void)addAnnotations
{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(32.084861, 118.887380);
    pointAnnotation.title = @"方恒国际";
    pointAnnotation.subtitle = @"阜通东大街6号";
    
    [_mapView addAnnotation:pointAnnotation];
    
//    [_mapView addAnnotations:@[]];
}

/**
 * @brief 地图加载成功
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView
{
    
}

- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView
{
    
}

/**
 * @brief 当mapView新添加annotation views时，调用此接口
 * @param mapView 地图View
 * @param views 新添加的annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //构造圆
    MACircle *circle = [MACircle circleWithCenterCoordinate:_mapView.userLocation.location.coordinate radius:1000];
    
    NSLog(@"%lf ---  %lf", _mapView.userLocation.location.coordinate.longitude, _mapView.userLocation.location.coordinate.latitude);
    //在地图上添加圆
    [_mapView addOverlay: circle];
    
//    [self addAnnotations];
}

/**
 * @brief 根据overlay生成对应的Renderer
 * @param mapView 地图View
 * @param overlay 指定的overlay
 * @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    NSLog(@"%lf ---  %lf", overlay.coordinate.longitude, overlay.coordinate.latitude);
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth    = 10.f;
        circleRenderer.strokeColor  = [UIColor colorWithRed:0.1 green:0.4 blue:1.0 alpha:0.6];
        circleRenderer.fillColor    = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:0.5];
        return circleRenderer;
    }
    return nil;
}

/**
 * @brief 根据anntation生成对应的View
 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
//{
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
