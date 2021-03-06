
//  Created by Airron on 15/12/11.
//  Copyright © 2015年 xxx. All rights reserved.
//

#import "CCQRCodeShowViewController.h"
#import "UIView+frameAdjust.h"
#import "UIColor+CCAddition.h"

@interface CCQRCodeShowViewController ()

@property (strong, nonatomic) UIView *qrCodeContainerView;
@property (strong, nonatomic) UIImageView *qrcodeView;
@property (strong, nonatomic) UILabel *remindLabel;
@property (strong, nonatomic) UIImageView *qrcodeIcon;

@end

@implementation CCQRCodeShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫码关注";
    
    [self layOutSubViews];
    NSString * qrcodeContentString = @"http://www.jianshu.com/users/e0d9d34fe19d/latest_articles";
    [self showQRCodeForResourceString:qrcodeContentString];
}

- (void)showQRCodeForResourceString:(NSString *)resourceString{
    
    UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:resourceString] withSize:self.qrcodeView.width];
    UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:46.0f andGreen:70.0f andBlue:134.0f];
    self.qrcodeView.image = customQrcode;
    
    //设置二维码阴影。
    self.qrcodeView.layer.shadowOffset = CGSizeMake(0, 2);
    self.qrcodeView.layer.shadowRadius = 2;
    self.qrcodeView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.qrcodeView.layer.shadowOpacity = 0.5;
}

- (void)layOutSubViews{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = screenSize.width/320.0;
    
    CGFloat qrcodeWidth = 250.0*scale;
    self.qrCodeContainerView = [[UIView alloc]initWithFrame:CGRectMake((screenSize.width - qrcodeWidth - 2)/2, 64*2-1, qrcodeWidth+1, qrcodeWidth+1)];
    self.qrCodeContainerView.layer.borderColor = [UIColor colorWithHexRGB:@"3b5b98"].CGColor;
    self.qrCodeContainerView.layer.borderWidth = 1.0;
    self.qrCodeContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.qrCodeContainerView];
    
    self.qrcodeView = [[UIImageView alloc]initWithFrame:CGRectMake(1, 1, qrcodeWidth, qrcodeWidth)];
    [self.qrCodeContainerView addSubview:self.qrcodeView];
    
    self.remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.qrCodeContainerView.x, self.qrCodeContainerView.bottom+40, self.qrCodeContainerView.width, 40)];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    self.remindLabel.textColor = [UIColor redColor];
    self.remindLabel.text = @"http://www.jianshu.com/users/e0d9d34fe19d/latest_articles";
    self.remindLabel.numberOfLines = 0;
    self.remindLabel.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:self.remindLabel];
    
    self.qrcodeIcon = [[UIImageView alloc]initWithFrame:CGRectMake((self.qrCodeContainerView.width-50.0)/2, (self.qrCodeContainerView.height-50)/2, 50, 50)];
    self.qrcodeIcon.image = [UIImage imageNamed:@"login_wechat_social.png"];
    [self.qrCodeContainerView addSubview:self.qrcodeIcon];
}

#pragma mark - InterpolatedUIImage
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *resultImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return resultImage;
}

#pragma mark - QRCodeGenerator
- (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
