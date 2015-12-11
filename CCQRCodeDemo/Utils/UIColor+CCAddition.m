//
//  UIColor+CCAddition.m
//  CloudCamera
//
//  Created by Yang.Lv on 15/5/20.
//  Copyright (c) 2015年 NetPower. All rights reserved.
//

#import "UIColor+CCAddition.h"

@implementation UIColor (CCAddition)

+ (UIColor *)colorWithHexRGB:(NSString *)rbg
{
    NSString *cString = [[rbg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if (cString.length < 6) {
        return [UIColor clearColor];
    }
    
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if (cString.length != 6) {
        return [UIColor clearColor];
    }
    
    NSRange range = NSMakeRange(0, 2);
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int red = 0;
    unsigned int green= 0;
    unsigned int blue = 0;
    [[NSScanner scannerWithString:rString] scanHexInt:&red];
    [[NSScanner scannerWithString:gString] scanHexInt:&green];
    [[NSScanner scannerWithString:bString] scanHexInt:&blue];
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

@end
