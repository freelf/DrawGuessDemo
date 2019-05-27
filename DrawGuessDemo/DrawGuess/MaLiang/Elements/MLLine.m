//
//  MLLine.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "MLLine.h"
#import "Maths.h"
@implementation MLLine
- (instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end pointSize:(CGFloat)pointSize pointStep:(CGFloat)pointStep color:(MLColor *)color {
    self = [super init];
    if (self) {
        self.begin = begin;
        self.end = end;
        self.pointSize = pointSize;
        self.pointStep = pointStep;
        self.color = color;
    }
    return self;
}
- (CGFloat)length {
    return [CGPointExtension distanceOfOnePoint:self.begin toOtherPoint:self.end];
}
- (CGFloat)angle {
    return [CGPointExtension angleOfOnePoint:self.end otherPoint:self.begin];
}
- (instancetype)copyWithZone:(NSZone *)zone {
    MLLine *line = [MLLine new];
    line.begin = self.begin;
    line.end = self.end;
    line.pointSize = self.pointSize;
    line.pointStep = self.pointStep;
    line.color = self.color;
    return line;
}
@end
