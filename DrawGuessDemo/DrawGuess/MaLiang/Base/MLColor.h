//
//  MLColor.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
@import simd;
@import UIKit;
@import Metal;

NS_ASSUME_NONNULL_BEGIN

@interface MLColor : NSObject
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;

- (vector_float4)toFloat4;
- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end

@interface UIColor (MLColor)
- (MLColor *)toMLColorWithOpacity:(CGFloat)opacity;
- (MTLClearColor)toClearColor;
@end
NS_ASSUME_NONNULL_END
