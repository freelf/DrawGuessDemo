//
//  RenderTarget.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import Metal;
@import simd;
NS_ASSUME_NONNULL_BEGIN

@interface RenderTarget : NSObject
@property (nonatomic, strong, readonly) id<MTLTexture> texture;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) MTLPixelFormat pixelFormat;
@property (nonatomic, assign) CGSize drawableSize;
@property (nonatomic, strong) id<MTLBuffer> uniform_buffer;
@property (nonatomic, strong) id<MTLBuffer> transform_buffer;
@property (nonatomic, strong, nullable) MTLRenderPassDescriptor *renderPassDescriptor;
@property (nonatomic, strong, nullable) id<MTLCommandBuffer> commandBuffer;
@property (nonatomic, strong, nullable) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong, nullable) id<MTLDevice> device;


- (instancetype)initWithSize:(CGSize)size pixelFormat:(MTLPixelFormat)pixelFormat device:(id<MTLDevice>)device;
- (void)clear;
- (void)updateBufferWithSize:(CGSize)size;
- (void)updateTransformBuffer;
- (void)prepareForDraw;
- (id<MTLRenderCommandEncoder>)makeCommandEncoder;
- (void)commitCommands;
- (id<MTLTexture>)makeEmptyTexture;

- (void)copyTextureToTexture:(id<MTLTexture>)texture;

@end

NS_ASSUME_NONNULL_END
