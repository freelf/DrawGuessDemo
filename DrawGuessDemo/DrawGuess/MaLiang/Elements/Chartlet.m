//
//  Chartlet.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Chartlet.h"
#import "Printer.h"
#import "Maths.h"
@implementation Chartlet
- (void)setIndex:(NSInteger)index {
    _index = index;
}
- (NSInteger)index {
    return  _index;
}
- (instancetype)initWithCenter:(CGPoint)center size:(CGSize)size textureId:(NSUUID *)textureId angle:(CGFloat)angle canvas:(Canvas *)canvas {
    self = [super init];
    if (self) {
        self.index = 0;
        CGPoint offset = canvas.contentOffset;
        CGFloat scale = canvas.scale;
        self.canvas = canvas;
        self.center = CGPointMake((center.x + offset.x) / scale, (center.y + offset.y) / scale);
        self.size = CGSizeMake(size.width / scale, size.height / scale);
        self.textureId = textureId;
        self.angle = angle;
    }
    return self;
}
- (void)drawSelfOnTarget:(RenderTarget *)target {
    [self.canvas.printer renderChartlet:self onRenderTarget:target];
}
- (id<MTLBuffer>)vertex_buffer {
    CGFloat scale = [UIScreen mainScreen].nativeScale;
    if (self.canvas.printer.target.contentScaleFactor) {
        scale = self.canvas.printer.target.contentScaleFactor;
    }
    CGPoint center = CGPointMake(self.center.x * scale, self.center.y * scale);
    CGSize halfSize = CGSizeMake(self.size.width * scale * 0.5, self.size.height * scale * 0.5);
    CGFloat angle = self.angle;
    CGPoint position1 = [CGPointExtension point:CGPointMake(center.x - halfSize.width, center.y - halfSize.height) rotateByAngle:angle anchor:center];
    CGPoint position2 = [CGPointExtension point:CGPointMake(center.x + halfSize.width, center.y - halfSize.height) rotateByAngle:angle anchor:center];
    CGPoint position3 = [CGPointExtension point:CGPointMake(center.x - halfSize.width, center.y + halfSize.height) rotateByAngle:angle anchor:center];
    CGPoint position4 = [CGPointExtension point:CGPointMake(center.x + halfSize.width, center.y + halfSize.height) rotateByAngle:angle anchor:center];
    vector_float4 vertex1 = [CGPointExtension pointToFloat4:position1];
    vector_float4 vertex2 = [CGPointExtension pointToFloat4:position2];
    vector_float4 vertex3 = [CGPointExtension pointToFloat4:position3];
    vector_float4 vertex4 = [CGPointExtension pointToFloat4:position4];
    Vertex vertices[] = {
        { .position = vertex1, .textCoord = {0, 0} },
        { .position = vertex2, .textCoord = {1, 0} },
        { .position = vertex3, .textCoord = {0, 1} },
        { .position = vertex4, .textCoord = {1, 1} }
    };
    return [[SharedDevice shareInstance].sharedDevice newBufferWithBytes:vertices length:sizeof(Vertex) * 4 options:MTLResourceCPUCacheModeWriteCombined];
}
@end
