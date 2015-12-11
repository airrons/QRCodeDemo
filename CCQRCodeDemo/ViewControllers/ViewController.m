
//  Created by Airron on 15/12/7.
//  Copyright © 2015年 xxx. All rights reserved.
//

#import "ViewController.h"
#import "CCQRCodeScanViewController.h"
#import "UIView+frameAdjust.h"
#import "CCQRCodeShowViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二维码";
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton * scanModePushButon = [UIButton buttonWithType:UIButtonTypeCustom];
    scanModePushButon.frame = CGRectMake((self.view.width-150)/2 , self.view.height/2-50, 150, 50);
    [scanModePushButon setTitle:@"ScanPush" forState:UIControlStateNormal];
    [scanModePushButon setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [scanModePushButon addTarget:self action:@selector(scanQRCode1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanModePushButon];
    
    UIButton * scanModePresentButon = [UIButton buttonWithType:UIButtonTypeCustom];
    scanModePresentButon.frame = CGRectMake((self.view.width-150)/2 , self.view.height/2+50, 150, 50);
    [scanModePresentButon setTitle:@"ScanPresent" forState:UIControlStateNormal];
    [scanModePresentButon setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [scanModePresentButon addTarget:self action:@selector(scanQRCode2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanModePresentButon];
    
    UIButton * qrcodeShowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qrcodeShowButton.frame = CGRectMake((self.view.width-150)/2 , self.view.height/2-50 + 200, 150, 50);
    [qrcodeShowButton setTitle:@"ShowQRCode" forState:UIControlStateNormal];
    [qrcodeShowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [qrcodeShowButton addTarget:self action:@selector(showQRCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrcodeShowButton];
}

- (void)showQRCode:(id)sender {
    CCQRCodeShowViewController * qrcodeVC = [[CCQRCodeShowViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:qrcodeVC animated:YES];
}

- (void)scanQRCode1:(id)sender {
    CCQRCodeScanViewController * qrcodeVC = [[CCQRCodeScanViewController alloc]initWithNibName:nil bundle:nil];
    qrcodeVC.displayMode = DisplayMode_Push;
    [self.navigationController pushViewController:qrcodeVC animated:YES];
}

- (void)scanQRCode2:(id)sender {
    
    CCQRCodeScanViewController * qrcodeVC = [[CCQRCodeScanViewController alloc]initWithNibName:nil bundle:nil];
    qrcodeVC.displayMode = DisplayMode_Present;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:qrcodeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
