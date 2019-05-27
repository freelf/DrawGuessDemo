//
//  Maths.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
@import simd;

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    vector_float4 position;
    vector_float2 textCoord;
} Vertex;
typedef struct {
    vector_float4 position;
    vector_float4 color;
    float angle;
    float size;
} MLPoint;
typedef struct {
    vector_float2 offset;
    float scale;
} ScrollingTransform;
typedef struct {
    vector_float4 color;
} ColorBuffer;

@interface Matrix : NSObject
+ (Matrix *)identity;
- (Matrix *)translationWithX:(float)x y:(float)y z:(float)z;
- (Matrix *)scalingWithX:(float)x y:(float)y z:(float)z;
- (float *)values;
@end

@interface CGPointExtension : NSObject
+ (CGPoint)middleOfOnePoint:(CGPoint)point otherPoint:(CGPoint)otherPoint;
+ (CGFloat)distanceOfOnePoint:(CGPoint)point toOtherPoint:(CGPoint)otherPoint;
+ (CGFloat)angleOfOnePoint:(CGPoint)point otherPoint:(CGPoint)otherPoint;
+ (vector_float4)pointToFloat4:(CGPoint)point;
+ (vector_float2)pointToFloat2:(CGPoint)point;
+ (CGPoint)point:(CGPoint)point offsetByX:(CGFloat)x y:(CGFloat)y;
+ (CGPoint)point:(CGPoint)point rotateByAngle:(CGFloat)angle anchor:(CGPoint)anchor;

@end

NS_ASSUME_NONNULL_END
