//
//  RenderTarget.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "RenderTarget.h"
#import "Maths.h"
@interface RenderTarget ()
@property (nonatomic, strong, readwrite, nullable) id<MTLTexture> texture;
@end
@implementation RenderTarget
- (instancetype)initWithSize:(CGSize)size pixelFormat:(MTLPixelFormat)pixelFormat device:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        self.zoom = 1;
        self.scale = 1;
        self.contentOffset = CGPointMake(0, 0);
        self.pixelFormat = MTLPixelFormatBGRA8Unorm;
        self.drawableSize = size;
        self.device = device;
        self.texture = [self makeEmptyTexture];
        self.commandQueue = [device newCommandQueue];
        self.pixelFormat = pixelFormat;
        self.renderPassDescriptor = [MTLRenderPassDescriptor new];
        MTLRenderPassColorAttachmentDescriptor *attachment = self.renderPassDescriptor.colorAttachments[0];
        attachment.texture = self.texture;
        attachment.loadAction = MTLLoadActionLoad;
        attachment.storeAction = MTLStoreActionStore;
        [self updateBufferWithSize:size];
    }
    return self;
}
- (void)clear {
    self.texture = [self makeEmptyTexture];
    self.renderPassDescriptor.colorAttachments[0].texture = self.texture;
}
- (void)updateBufferWithSize:(CGSize)size {
    self.drawableSize = size;
    Matrix *matrix = [Matrix identity];
    CGFloat zoomUniform = 2 * self.zoom / self.scale;
    matrix = [matrix scalingWithX:zoomUniform / size.width y:-zoomUniform / size.height z:1];

    matrix = [matrix translationWithX:-1 y:1 z:0];
    
    self.uniform_buffer = [self.device newBufferWithBytes:matrix.values length:sizeof(float) * 16 options:MTLResourceCPUCacheModeDefaultCache];
    [self updateTransformBuffer];
}
- (void)updateTransformBuffer {
    CGFloat scaleFactor = [[UIScreen mainScreen]nativeScale];
    ScrollingTransform transform = {{self.contentOffset.x * scaleFactor, self.contentOffset.y * scaleFactor}, self.scale};
    self.transform_buffer = [self.device newBufferWithBytes:&transform length:sizeof(transform) options:MTLResourceCPUCacheModeDefaultCache];
}
- (void)prepareForDraw {
    if (!self.commandBuffer) {
        self.commandBuffer = [self.commandQueue commandBuffer];
    }
}
- (id<MTLRenderCommandEncoder>)makeCommandEncoder {
    if (self.commandBuffer && self.renderPassDescriptor) {
        return [self.commandBuffer renderCommandEncoderWithDescriptor:self.renderPassDescriptor];
    }
    return nil;
}
- (void)commitCommands {
    [self.commandBuffer commit];
    self.commandBuffer = nil;
}
- (id<MTLTexture>)makeEmptyTexture {
    if (self.drawableSize.width * self.drawableSize.height <= 0) {
        return nil;
    }
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:self.pixelFormat width:self.drawableSize.width height:self.drawableSize.height mipmapped:NO];
    textureDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    return [self.device newTextureWithDescriptor:textureDescriptor];
}
- (void)copyTextureToTexture:(id<MTLTexture>)texture {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id <MTLBlitCommandEncoder> blitCommandEncoder = [commandBuffer blitCommandEncoder];
    MTLRegion region = MTLRegionMake2D(0, 0, self.drawableSize.width, self.drawableSize.height);
    [blitCommandEncoder copyFromTexture:self.texture sourceSlice:0 sourceLevel:0 sourceOrigin:region.origin sourceSize:region.size toTexture:texture destinationSlice:0 destinationLevel:0 destinationOrigin:region.origin];
    [blitCommandEncoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}
@end
