
//  Created by Airron on 15/12/10.
//  Copyright © 2015年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    DisplayMode_Push,
    DisplayMode_Present,
} DisplayMode;

@interface CCQRCodeScanViewController : UIViewController

@property (nonatomic,assign)DisplayMode displayMode;

@end
