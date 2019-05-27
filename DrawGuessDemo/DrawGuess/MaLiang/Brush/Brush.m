//
//  Brush.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Brush.h"
#import "LineStrip.h"

@interface Brush ()
@property (nonatomic, strong, readwrite) NSUUID *textureId;
@property (nonatomic, weak, readwrite) Canvas *target;
@property (nonatomic, weak, readwrite) id<MTLTexture> texture;
@property (nonatomic, strong, readwrite) id<MTLRenderPipelineState> piplineState;
@property (nonatomic, assign) CGFloat canvasScale;
@property (nonatomic, assign) CGPoint canvasOffset;
@end

@implementation Brush
// MARK: - Setter & Getter
- (void)setOpacity:(CGFloat)opacity {
    _opacity = opacity;
    [self updateRenderingColor];
}
- (void)setColor:(UIColor *)color {
    _color = color;
    [self updateRenderingColor];
}
- (CGFloat)canvasScale {
    if (self.target) {
        return self.target.screenTarget.scale;
    }
    return 1;
}
- (CGPoint)canvasOffset {
    if (self.target) {
        return self.target.screenTarget.contentOffset;
    }
    return CGPointZero;
}
// MARK: - Init
- (instancetype)initWithName:(NSString *)name textureId:(NSUUID *)textureId target:(Canvas *)target {
    self = [super init];
    if (self) {
        self.opacity = 0.3;
        self.pointSize = 4;
        self.pointStep = 1;
        self.forceSensitive = 0;
        self.scaleWithCanvas = NO;
        self.forceOnTap = 1;
        self.rotationFixedCoefficient = 0;
        self.color = [UIColor blackColor];
        self.rotation = RotationFixed;
        
        self.name = name ? name : textureId.UUIDString;
        self.target = target;
        self.textureId = textureId;
        if (textureId) {
            self.texture = [target findTextureByUUID:textureId].texture;
        }
        [self updatePointPipeline];
    }
    return self;
}

// MARK: - Render Action
- (void)updatePointPipeline {
    id<MTLLibrary> library = [self makeShaderLibraryFromDevice:self.target.device];
    Canvas *target = self.target;
    id<MTLDevice> device = target.device;
    if (!target || !device || !library) {
        return;
    }
    MTLRenderPipelineDescriptor *rpd = [MTLRenderPipelineDescriptor new];
    id<MTLFunction> vertex_func = [self makeShaderVertexFunctionFromLibrary:library];
    id<MTLFunction> fragment_func = [self makeShaderFragmentFunctionFromLibrary:library];
    if (vertex_func) {
        rpd.vertexFunction = vertex_func;
    }
    if (fragment_func) {
        rpd.fragmentFunction = fragment_func;
    }
    rpd.colorAttachments[0].pixelFormat = target.colorPixelFormat;
    [self setupBlendOptionForAttachment:rpd.colorAttachments[0]];
    NSError *error;
    self.piplineState = [device newRenderPipelineStateWithDescriptor:rpd error:&error];
}
- (void)renderLineStrip:(LineStrip *)lineStrip onRenderTarget:(RenderTarget *)target {
    RenderTarget *renderTarget = self.target.screenTarget;
    if (target) {
        renderTarget = target;
    }
    if (lineStrip.lines.count <= 0 || !renderTarget) {
        return;
    }
    [renderTarget prepareForDraw];
    id<MTLRenderCommandEncoder> commandEncoder = [renderTarget makeCommandEncoder];
    [commandEncoder setRenderPipelineState:self.piplineState];
    id<MTLBuffer> vertex_buffer = [lineStrip retrieveBuffersRotation:self.rotation];
    if (vertex_buffer) {
        [commandEncoder setVertexBuffer:vertex_buffer offset:0 atIndex:0];
        [commandEncoder setVertexBuffer:renderTarget.uniform_buffer offset:0 atIndex:1];
        [commandEncoder setVertexBuffer:renderTarget.transform_buffer offset:0 atIndex:2];
        if (self.texture) {
            [commandEncoder setFragmentTexture:self.texture atIndex:0];
        }
        [commandEncoder drawPrimitives:MTLPrimitiveTypePoint vertexStart:0 vertexCount:lineStrip.vertexCount];
    }
    [commandEncoder endEncoding];
}



// MARK: - Public Method
- (void)use {
    self.target.currentBrush = self;
}
- (NSArray<MLLine *> *)makeLineFrom:(Pan)from to:(Pan)to {
    if (from.force > 0 && to.force >= from.force * 5) {
        return @[];
    }
    CGFloat endForce = from.force * 0.95 + to.force * 0.05;
    CGFloat forceRate = pow(endForce, self.forceSensitive);
    return [self makeLineFrom:from.point to:to.point force:forceRate uniqueColor:NO];
}
- (NSArray<MLLine *> *)makeLineFrom:(CGPoint)from to:(CGPoint)to force:(CGFloat)force uniqueColor:(BOOL)uniqueColor {
    CGFloat scale = self.scaleWithCanvas ? 1 : self.canvasScale;
    CGFloat fromX = (from.x + self.canvasOffset.x) / self.canvasScale;
    CGFloat fromY = (from.y + self.canvasOffset.y) / self.canvasScale;
    
    CGFloat toX = (to.x + self.canvasOffset.x) / self.canvasScale;
    CGFloat toY = (to.y + self.canvasOffset.y) / self.canvasScale;
    MLLine *line = [[MLLine alloc]initWithBegin:CGPointMake(fromX, fromY)
                                            end:CGPointMake(toX, toY)
                                      pointSize:self.pointSize * force / scale
                                      pointStep:self.pointStep / scale
                                          color:uniqueColor ? self.renderingColor : nil];
    return @[line];
}
- (NSArray<MLLine *> *)finishLineStripAtEnd:(Pan)end {
    return @[];
}
// MARK: - Private Method
- (void)updateRenderingColor {
    self.renderingColor = [self.color toMLColorWithOpacity:self.opacity];
}

// MARK: - Render Tools

- (id<MTLLibrary>)makeShaderLibraryFromDevice:(id<MTLDevice>)device {
    return  [device newDefaultLibrary];
}
- (id<MTLFunction>)makeShaderVertexFunctionFromLibrary:(id<MTLLibrary>)library {
    return [library newFunctionWithName:@"vertex_point_func"];
}
- (id<MTLFunction>)makeShaderFragmentFunctionFromLibrary:(id<MTLLibrary>)library {
    if (!self.texture) {
        return [library newFunctionWithName:@"fragment_point_func_without_texture"];
    }
    return [library newFunctionWithName:@"fragment_point_func"];
}
- (void)setupBlendOptionForAttachment:(MTLRenderPipelineColorAttachmentDescriptor *)attachment {
    attachment.blendingEnabled = YES;
    attachment.rgbBlendOperation = MTLBlendOperationAdd;
    attachment.sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    attachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    attachment.alphaBlendOperation = MTLBlendOperationAdd;
    attachment.sourceAlphaBlendFactor = MTLBlendFactorOne;
    attachment.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
}
@end
