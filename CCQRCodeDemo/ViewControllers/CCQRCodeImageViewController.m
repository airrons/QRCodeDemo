
//  Created by Airron on 15/12/11.
//  Copyright © 2015年 xxx. All rights reserved.
//

#import "CCQRCodeImageViewController.h"
#import "UIView+frameAdjust.h"

@interface CCQRCodeImageViewController ()

@property (nonatomic,strong)UIImageView * qrcodeImageView;

@end

@implementation CCQRCodeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二维码";
    
    [self layOutSubViews];
    
    UIBarButtonItem * doneBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneBarButtonTouched:)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    // Do any additional setup after loading the view.
}

- (void)onDoneBarButtonTouched:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.selectImageHandler) {
        self.selectImageHandler(self.qrcodeImageView.image);
    }
}


- (void)layOutSubViews{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = screenSize.width/320.0;
    
    CGFloat qrcodeWidth = 250.0*scale;
    self.qrcodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenSize.width - qrcodeWidth)/2, 64*2, qrcodeWidth, qrcodeWidth)];
    self.qrcodeImageView.image = [UIImage imageNamed:@"sample.png"];
    [self.view addSubview:self.qrcodeImageView];
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
