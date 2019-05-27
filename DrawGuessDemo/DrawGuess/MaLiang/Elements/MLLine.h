//
//  MLLine.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLColor.h"
@import CoreGraphics;

NS_ASSUME_NONNULL_BEGIN

@interface MLLine : NSObject<NSCopying>
@property (nonatomic, assign) CGPoint begin;
@property (nonatomic, assign) CGPoint end;

@property (nonatomic, assign) CGFloat pointSize;
@property (nonatomic, assign) CGFloat pointStep;

@property (nonatomic, strong) MLColor *color;

@property (nonatomic, assign) CGFloat length;
@property (nonatomic, assign) CGFloat angle;

- (instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end pointSize:(CGFloat)pointSize pointStep:(CGFloat)pointStep color:(MLColor *)color;
@end

NS_ASSUME_NONNULL_END
