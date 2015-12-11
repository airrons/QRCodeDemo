
//  Created by Airron on 15/12/10.
//  Copyright © 2015年 xxx. All rights reserved.
//

#import "CCQRCodeScanViewController.h"
#import "NSObject+GCD.h"
#import "UIView+frameAdjust.h"
#import "MBProgressHUD.h"
#import "CCQRCodeImageViewController.h"

@interface CCQRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIImageView *scanBackgrondImageView;

@property (strong, nonatomic) UIView *scanView;

@property (strong, nonatomic) UILabel *statusLabel;

@property(strong,nonatomic) AVCaptureSession *session; // 二维码生成的会话

@property(strong,nonatomic)  AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic,strong) UIImageView * readLineView;

@property(nonatomic,strong) MBProgressHUD *indicator;

@property (nonatomic,strong) CALayer * maskLayer;//扫描器灰色蒙板。

@property(nonatomic,strong) CIDetector * detector;

@property(nonatomic,assign) CMVideoDimensions dimensions;

@end

@implementation CCQRCodeScanViewController


- (void)dealloc{
    
    // 删除预览图层
    if (self.previewLayer) {
        [self.previewLayer removeFromSuperlayer];
    }
    if (self.maskLayer) {
        self.maskLayer.delegate = nil;
    }
    NSLog(@"%@ will dealloc !",NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopScanning:self.session];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.session) {
        [self readQRcode];
    }else{
        [self startScanning:self.session];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫码关注";
    [self layoutSubViews];
    
    UIBarButtonItem * scanSystemAlbumQRCodeBarButton = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(scanSystemAlbumQRCode:)];
    self.navigationItem.rightBarButtonItem = scanSystemAlbumQRCodeBarButton;
    
    UIBarButtonItem * doneBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneBarButtonTouched:)];
    if (self.displayMode == DisplayMode_Present) {
        self.navigationItem.leftBarButtonItem = doneBarButton;
    }
}

- (void)onDoneBarButtonTouched:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (BOOL)isCurrentDeviceBeforeiOS8{
    // iOS < 8.0
    return [[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending;
}

//ios8.0及以上版本可使用。
- (CIDetector *)detector{
    if (_detector == nil) {
        NSDictionary * options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:options];
    }
    return _detector;
}

- (void)scanSystemAlbumQRCode:(id)sender{
    
    if ([CCQRCodeScanViewController isCurrentDeviceBeforeiOS8]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示:" message:@"IOS8.0以下系统无原生API支持扫描相片二维码，请选择其他第三方识别二维码库" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if (self.session) {
        [self stopScanning:self.session];
    }
    
    __weak CCQRCodeScanViewController * weakSelf = self;
    CCQRCodeImageViewController * qrcodeImageVC = [[CCQRCodeImageViewController alloc]initWithNibName:nil bundle:nil];
    qrcodeImageVC.selectImageHandler = ^(UIImage * selectedImage){

        UIImage * image = [UIImage imageNamed:@"sample.png"];
        NSMutableString * result = [NSMutableString stringWithString:@""];
        CIImage * ciImage = [[CIImage alloc]initWithImage:image];
        NSArray * features = [weakSelf.detector featuresInImage:ciImage];
        for (CIQRCodeFeature * feature in features) {
            [result appendString:feature.messageString];
        }
        if (result) {
            weakSelf.statusLabel.text = result;
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:result]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
            }
        }
    };
    [self.navigationController pushViewController:qrcodeImageVC animated:YES];
}

- (void)layoutSubViews{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = screenSize.width/320.0;
    
    CGFloat scanViewWidth = 240.0*scale;
    self.scanView = [[UIView alloc]initWithFrame:CGRectMake((screenSize.width-scanViewWidth)/2.0, 64.0+64.0, scanViewWidth, scanViewWidth)];
    [self.view addSubview:self.scanView];
    
    self.scanBackgrondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scanView.x-2, self.scanView.y-2, self.scanView.width+4, self.scanView.height+4)];
    self.scanBackgrondImageView.image = [UIImage imageNamed:@"family_scan_frame.png"];
    [self.view insertSubview:self.scanBackgrondImageView belowSubview:self.scanView];
    
    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.scanView.x-20, self.scanView.bottom + 40, self.scanView.width+40, 40)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor redColor];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:self.statusLabel];
}

#pragma mark 扫描动画
-(void)loopDrawLine{
    
    CGRect rect = CGRectMake(0, 5, self.scanBackgrondImageView.width, 2);
    if (_readLineView) {
        [_readLineView removeFromSuperview];
    }
    __weak CCQRCodeScanViewController *weakSelf = self;
    weakSelf.readLineView = [[UIImageView alloc] initWithFrame:rect];
    [_readLineView setImage:[UIImage imageNamed:@"family_scan.png"]];
    [UIView animateWithDuration:1.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         //修改fream的代码写在这里
                         weakSelf.readLineView.frame =CGRectMake(0, weakSelf.scanBackgrondImageView.height - 5, self.scanBackgrondImageView.width, 2);
                         [weakSelf.readLineView setAnimationRepeatCount:0];
                         
                     }
                     completion:^(BOOL finished){
                         [weakSelf loopDrawLine];
                     }];
    
    [weakSelf.scanBackgrondImageView addSubview:weakSelf.readLineView];
}


#pragma mark - 读取二维码

- (void)readQRcode{
    
    // 1. 摄像头设备
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入
    
    // 因为模拟器是没有摄像头的，因此在此最好做一个判断
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        
        return;
    }
    
    // 3. 设置输出(Metadata元数据)
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 3.1 设置输出的代理
    
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 拍摄会话
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
        session.sessionPreset = AVCaptureSessionPreset1920x1080;//设置图像输出质量
        self.dimensions = (CMVideoDimensions){1080,1920};
    }else if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]){
        session.sessionPreset = AVCaptureSessionPreset1280x720;
        self.dimensions = (CMVideoDimensions){720,1280};
    }else if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset640x480]){
        session.sessionPreset = AVCaptureSessionPreset640x480;
        self.dimensions = (CMVideoDimensions){480,640};
    }else if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset352x288]){
        session.sessionPreset = AVCaptureSessionPreset352x288;
        self.dimensions = (CMVideoDimensions){288,352};
    }
    
    // 添加session的输入和输出
    
    [session addInput:input];
    
    [session addOutput:output];
    
    // 4.1 设置输出的格式
    
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    CGRect scanBounds = self.view.bounds;
    
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    // 5.1 设置preview图层的属性
    
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // 5.2 设置preview图层的大小
    
    [preview setFrame:scanBounds];
    
    preview.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    // 5.3 将图层添加到视图的图层
    
    [self.view.layer insertSublayer:preview atIndex:0];
    
    self.previewLayer = preview;
    
    self.maskLayer = [[CALayer alloc]init];
    self.maskLayer.frame = scanBounds;
    self.maskLayer.delegate = self;
    [self.view.layer insertSublayer:self.maskLayer above:self.previewLayer];
    [self.maskLayer setNeedsDisplay];
    
    
    //5.4设置扫描区域
    
    /*获取图像输出大小*/
    CMVideoDimensions dimensions = self.dimensions;
    CGFloat width = dimensions.width;
    CGFloat height = dimensions.height;
    
    CGSize size = scanBounds.size;
    CGRect cropRect = [self.view convertRect:self.scanView.frame fromView:self.scanView.superview];
    
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = height/width; //与之前设置的图像输出质量应该对应。
    if (p1 < p2) {
        CGFloat fixHeight = self.view.bounds.size.width * height / width; //缩放并剪裁后的高度。
        CGFloat fixPadding = (fixHeight - size.height)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.view.bounds.size.height * width / height;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    //说明: rectOfInterest 参数和普通的Rect范围不太一样，它的四个值的范围都是0-1，表示比例
    //      参数里的x对应的恰恰是距离左上角的垂直距离，y对应的是距离左上角的水平距离,宽度和高度设置的情况也是类似
    //      举个例子如果我们想让扫描的处理区域是屏幕的下半部分，我们这样设置  output.rectOfInterest=CGRectMake(0.5,0,0.5, 1)
    
    // 6. 启动会话
    
    [self startScanning:session];
    
    self.session = session;
}

//扫码完成后退出。
- (void)dismissIfNeed{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//停止扫描
- (void)stopScanning:(AVCaptureSession *)session{
    
    [session stopRunning];
    safe_dispatch_main_async(^{
        
    });
}

//开始扫描
- (void)startScanning:(AVCaptureSession *)session{
    [session startRunning];
    safe_dispatch_main_async(^{
        if (_readLineView) {
            [self.scanBackgrondImageView.layer removeAllAnimations];
        }else{
            [self loopDrawLine];
        }
    });
}

#pragma mark - 输出代理方法

// 此方法是在识别到QRCode，并且完成转换

// 如果QRCode的内容越大，转换需要的时间就越长

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // 扫描结果
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *result = obj.stringValue;
        
        [self handleScanResult:result];
    }
}

//处理请求得到的家庭相册二维码信息，解析完成后向服务器发送请求添加到家庭相册请求。
- (void)handleScanResult:(NSString *)result{
    //扫描的到内容，立即停止扫描。避免重复扫描的出现。
    [self stopScanning:self.session];
    if (result) {
        [self showRemindStringOnWindow:result autoHide:YES];
        if (self.displayMode == DisplayMode_Present) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else if (self.displayMode == DisplayMode_Push){
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.statusLabel.text = result;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:result]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
        }
    }
}



//Note: 蒙板生成。需设置代理，并在退出页面时取消代理。
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if (layer == self.maskLayer) {
        UIGraphicsBeginImageContextWithOptions(self.maskLayer.frame.size, NO, 1.0);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor);
        CGContextFillRect(ctx, self.maskLayer.frame);
        CGRect scanFrame = [self.view convertRect:self.scanView.frame fromView:self.scanView.superview];
        CGContextClearRect(ctx, scanFrame);
    }
}

- (void)showRemindStringOnWindow:(NSString *)remindString autoHide:(BOOL)autoHide{
    if (self.indicator) {
        [self.indicator hide:YES];
        self.indicator = nil;
    }
    if (autoHide) {
        UIWindow * window = [[[UIApplication sharedApplication] windows] lastObject];
        self.indicator =  [MBProgressHUD showHUDAddedTo:window animated:YES];
        self.indicator.mode = MBProgressHUDModeText;
        [self.indicator hide:YES afterDelay:1.5];
    }else{
        self.indicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    self.indicator.detailsLabelText = remindString;
    self.indicator.detailsLabelFont = [UIFont systemFontOfSize:16.0];
    self.indicator.removeFromSuperViewOnHide = YES;
    self.indicator.userInteractionEnabled = NO;
    [self.indicator show:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
