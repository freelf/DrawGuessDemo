//
//  LineStrip.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "LineStrip.h"
#import "Maths.h"
@interface LineStrip ()
@property (nonatomic, strong, readwrite) NSMutableArray<MLLine *> *lines;
@property (nonatomic, strong) id<MTLBuffer> vertex_buffer;
@property (nonatomic, assign, readwrite) NSInteger vertexCount;
@end
@implementation LineStrip
- (void)setIndex:(NSInteger)index {
    _index = index;
}
- (NSInteger)index {
    return _index;
}
- (instancetype)initLines:(NSArray<MLLine *> *)lines brush:(Brush *)brush {
    self = [super init];
    if (self) {
        self.index = 0;
        self.lines = [NSMutableArray arrayWithArray:lines];
        self.brush = brush;
        self.brushName = brush.name;
        self.color = brush.renderingColor;
        [self remakBufferRotation:brush.rotation withFixedAngle:brush.rotationFixedCoefficient];
    }
    return self;
}
- (void)appendLines:(NSArray<MLLine *> *)lines {
    [self.lines addObjectsFromArray:lines];
    self.vertex_buffer = nil;
}
- (void)drawSelfOnTarget:(RenderTarget *)target {
    [self.brush renderLineStrip:self onRenderTarget:target];
}
- (id<MTLBuffer>)retrieveBuffersRotation:(Rotation)rotation {
    if (self.vertex_buffer == nil) {
        [self remakBufferRotation:rotation withFixedAngle:self.brush.rotationFixedCoefficient];
    }
    return self.vertex_buffer;
}
// MARK: - Private
- (void)remakBufferRotation:(Rotation)rotation withFixedAngle:(CGFloat)angle {
    if (self.lines.count <= 0) {
        return;
    }
    NSMutableArray<NSValue *> *array = @[].mutableCopy;
    typedef struct {
        CGRect position;
        CGRect color;
        float angle;
        float size;
    } TempPoint;
    for (int i = 0; i < self.lines.count; i++) {
        MLLine *line = [self.lines[i] copy];
        CGFloat scale = [UIScreen mainScreen].nativeScale;
        if (self.brush.target) {
            scale = self.brush.target.contentScaleFactor;
        }
        line.begin = CGPointMake(line.begin.x * scale, line.begin.y * scale);
        line.end = CGPointMake(line.end.x * scale, line.end.y * scale);
        CGFloat count = MAX(line.length / line.pointStep, 1);
        for (int index = 0; index < (int)count; index++) {
            CGFloat x = line.begin.x + (line.end.x - line.begin.x) * (index / count);
            CGFloat y = line.begin.y + (line.end.y - line.begin.y) * (index / count);
            CGFloat angle = 0;
            switch (rotation) {
                case RotationFixed:
                    angle = angle;
                    break;
                case RotationRandom:
                    angle = -(arc4random() / M_PI) + arc4random() /  M_PI;
                    break;
                case RotationAhead:
                    angle = line.angle;
                    break;
            }
            MLColor *color = self.color;
            if (line.color) {
                color = line.color;
            }
            TempPoint point = {CGRectMake(x, y, 0, 1), CGRectMake(color.red, color.green, color.blue, color.alpha), angle, line.pointSize * scale};
            NSValue *value = [NSValue valueWithBytes:&point objCType:@encode(TempPoint)];
            [array addObject:value];
        }
    }
    MLPoint *pointArray = (MLPoint *)malloc(sizeof(MLPoint) * array.count);
    for (int i = 0; i < array.count; i++) {
        TempPoint point;
        [array[i] getValue:&point];
        vector_float4 position = {point.position.origin.x, point.position.origin.y, 0, 1};
        vector_float4 color = {point.color.origin.x, point.color.origin.y, point.color.size.width, point.color.size.height};
        MLPoint mlPoint = {position, color, point.angle, point.size};
        pointArray[i] = mlPoint;
    }
    self.vertexCount = array.count;
    self.vertex_buffer = [[SharedDevice shareInstance].sharedDevice newBufferWithBytes:pointArray length:sizeof(MLPoint) * array.count options:MTLResourceCPUCacheModeWriteCombined];
    free(pointArray);
}
@end
