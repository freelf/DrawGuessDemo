//
//  Brush.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Canvas.h"
#import "MLColor.h"
#import "MLLine.h"
@class LineStrip;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Rotation) {
    RotationFixed,
    RotationRandom,
    RotationAhead,
};
typedef struct {
    CGPoint point;
    CGFloat force;
} Pan;
@interface Brush : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, readonly) NSUUID *textureId;
@property (nonatomic, weak, readonly) Canvas *target;
@property (nonatomic, assign) CGFloat opacity; // 默认0.3
@property (nonatomic, assign) CGFloat pointSize;
@property (nonatomic, assign) CGFloat pointStep;
@property (nonatomic, assign) CGFloat forceSensitive; // 压力感
@property (nonatomic, assign) BOOL scaleWithCanvas;
@property (nonatomic, assign) CGFloat forceOnTap;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) Rotation rotation;
@property (nonatomic, assign) Rotation rotationFixedCoefficient;
@property (nonatomic, strong) MLColor *renderingColor;
@property (nonatomic, weak, readonly) id<MTLTexture> texture;
@property (nonatomic, strong, readonly) id<MTLRenderPipelineState> piplineState;

- (instancetype)initWithName:(nullable NSString *)name textureId:(nullable NSUUID *)textureId target:(Canvas *)target;
- (void)setupBlendOptionForAttachment:(MTLRenderPipelineColorAttachmentDescriptor *)attachment;
- (void)use;
- (id<MTLFunction>)makeShaderVertexFunctionFromLibrary:(id<MTLLibrary>)library;
- (id<MTLFunction>)makeShaderFragmentFunctionFromLibrary:(id<MTLLibrary>)library;
- (id<MTLLibrary>)makeShaderLibraryFromDevice:(id<MTLDevice>)device;
- (NSArray<MLLine *> *)makeLineFrom:(Pan)from to:(Pan)to;
- (NSArray<MLLine *> *)makeLineFrom:(CGPoint)from to:(CGPoint)to force:(CGFloat)force uniqueColor:(BOOL)uniqueColor;
- (NSArray<MLLine *> *)finishLineStripAtEnd:(Pan)end;

- (void)renderLineStrip:(LineStrip *)lineStrip onRenderTarget:(RenderTarget *)target;
@end

NS_ASSUME_NONNULL_END
