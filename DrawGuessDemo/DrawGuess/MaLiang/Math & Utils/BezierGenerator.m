//
//  BezierGenerator.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "BezierGenerator.h"
#import "Maths.h"
@interface BezierGenerator ()
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, strong) NSDictionary<NSNumber * , NSNumber *> *styleStep;
@end
@implementation BezierGenerator
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.step = 0;
        self.styleStep = @{@(BezierGeneratorStyleLinear) : @(NSIntegerMax),
                           @(BezierGeneratorStyleQuadratic) : @(3),
                           @(BezierGeneratorStyleCubic) : @(NSIntegerMax)
                           };
        self.points = @[].mutableCopy;
        self.style = BezierGeneratorStyleQuadratic;
    }
    return self;
}
- (instancetype)initWithBeginPoint:(CGPoint)point {
    self = [super init];
    if (self) {
        [self beginWithPoint:point];
    }
    return self;
}
- (void)beginWithPoint:(CGPoint)point {
    [self.points addObject:[NSValue valueWithCGPoint:point]];
}
- (NSArray<NSValue *> *)pushPoint:(CGPoint)point {
    if (CGPointEqualToPoint(point, [self.points.lastObject CGPointValue])) {
        return @[];
    }
    [self.points addObject:[NSValue valueWithCGPoint:point]];
    if (self.points.count < self.styleStep[@(self.style)].integerValue) {
        return @[];
    }
    self.step += 1;
    NSArray<NSValue *> *result = [self genericPathPoints];
    return result;
}
- (void)finish {
    self.step = 0;
    [self.points removeAllObjects];
}
- (NSArray<NSValue *> *)genericPathPoints {
    CGPoint begin,control;
    CGPoint end = [CGPointExtension middleOfOnePoint:[self.points[self.step]CGPointValue] otherPoint:[self.points[self.step + 1]CGPointValue]];
    NSMutableArray<NSValue *> *vertices = @[].mutableCopy;
    if (self.step == 1) {
        begin = self.points[0].CGPointValue;
        CGPoint middle1 = [CGPointExtension middleOfOnePoint:self.points[0].CGPointValue otherPoint:self.points[1].CGPointValue];
        control = [CGPointExtension middleOfOnePoint:middle1 otherPoint:self.points[1].CGPointValue];
    } else {
        begin = [CGPointExtension middleOfOnePoint:self.points[self.step - 1].CGPointValue otherPoint:self.points[self.step].CGPointValue];
        control = self.points[self.step].CGPointValue;
    }
    CGFloat distance = [CGPointExtension distanceOfOnePoint:begin toOtherPoint:end];
    NSInteger segements = MAX((int)(distance / 5), 2);
    for (int i = 0; i < segements; i++) {
        CGFloat t = (CGFloat)i / (CGFloat)segements;
        CGFloat x = pow(1 - t, 2) * begin.x + 2.0 * (1 - t) * t * control.x + t * t * end.x;
        CGFloat y = pow(1 - t, 2) * begin.y + 2.0 * (1 - t) * t * control.y + t * t * end.y;
        [vertices addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    [vertices addObject:[NSValue valueWithCGPoint:end]];
    return vertices;
 }
@end
