//
//  MLColor.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "MLColor.h"


@implementation MLColor
- (vector_float4)toFloat4 {
    vector_float4 float4 = {self.red, self.green, self.blue, self.alpha};
    return float4;
}
- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    self = [super init];
    if (self) {
        self.red = red;
        self.green = green;
        self.blue = blue;
        self.alpha = alpha;
    }
    return self;
}
@end
@implementation UIColor (MLColor)
- (MLColor *)toMLColorWithOpacity:(CGFloat)opacity {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return [[MLColor alloc]initWithRed:red green:green blue:blue alpha:alpha * opacity];
}
- (MTLClearColor)toClearColor {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return MTLClearColorMake(red, green, blue, alpha);
}
@end
