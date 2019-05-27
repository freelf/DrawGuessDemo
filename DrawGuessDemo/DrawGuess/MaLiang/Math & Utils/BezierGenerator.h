//
//  BezierGenerator.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
@import UIKit;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BezierGeneratorStyle) {
    BezierGeneratorStyleLinear,
    BezierGeneratorStyleQuadratic,
    BezierGeneratorStyleCubic,
};
@interface BezierGenerator : NSObject
@property (nonatomic, strong) NSMutableArray<NSValue *> *points;
@property (nonatomic, assign) BezierGeneratorStyle style;

- (instancetype)initWithBeginPoint:(CGPoint)point;
- (void)beginWithPoint:(CGPoint)point;
- (NSArray<NSValue *>*)pushPoint:(CGPoint)point;
- (void)finish;
@end

NS_ASSUME_NONNULL_END
