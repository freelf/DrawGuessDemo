//
//  Maths.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Maths.h"

@interface Matrix ()
{
    float m[16];
}
@end

@implementation Matrix
+ (Matrix *)identity {
    return [Matrix new];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        m[0] = 1;
        m[5] = 1;
        m[10] = 1;
        m[15] = 1;
    }
    return self;
}
- (Matrix *)translationWithX:(float)x y:(float)y z:(float)z {
    m[12] = x;
    m[13] = y;
    m[14] = z;
    return self;
}
- (Matrix *)scalingWithX:(float)x y:(float)y z:(float)z {
    m[0] = x;
    m[5] = y;
    m[10] = z;
    return self;
}
- (float *)values {
    return &m[0];
}
@end
@implementation CGPointExtension

+ (CGPoint)middleOfOnePoint:(CGPoint)point otherPoint:(CGPoint)otherPoint {
    return CGPointMake((point.x + otherPoint.x) * 0.5, (point.y + otherPoint.y) * 0.5);
}
+ (CGFloat)distanceOfOnePoint:(CGPoint)point toOtherPoint:(CGPoint)otherPoint {
    CGFloat p = pow(point.x - otherPoint.x, 2) + pow(point.y - otherPoint.y, 2);
    return sqrt(p);
}
+ (CGFloat)angleOfOnePoint:(CGPoint)point otherPoint:(CGPoint)otherPoint {
    CGPoint p = CGPointMake(point.x - otherPoint.x, point.y - otherPoint.y);
    if (point.y == 0) {
        return point.x >= 0 ? 0 : M_PI;
    }
    return -atan2f(p.y, p.x);
}
+ (vector_float4)pointToFloat4:(CGPoint)point {
    vector_float4 float4 = {point.x, point.y, 0, 1};
    return float4;
}
+ (vector_float2)pointToFloat2:(CGPoint)point {
    vector_float2 float2 = {point.x , point.y};
    return float2;
}
+ (CGPoint)point:(CGPoint)point offsetByX:(CGFloat)x y:(CGFloat)y {
    return CGPointMake(point.x += x, point.y += y);
}
+ (CGPoint)point:(CGPoint)point rotateByAngle:(CGFloat)angle anchor:(CGPoint)anchor {
    CGPoint p = CGPointMake(point.x - anchor.x, point.y - anchor.y);
    CGFloat a = -angle;
    CGFloat x = p.x;
    CGFloat y = p.y;
    
    CGFloat x_ = x * cos(a) - y * sin(a);
    CGFloat y_ = x * sin(a) + y * cos(a);
    return CGPointMake(x_ + anchor.x, y_ + anchor.y);
    
}

@end
