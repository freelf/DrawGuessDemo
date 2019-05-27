//
//  MetalView.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "MetalView.h"
#import "Maths.h"
#import "MLColor.h"


@implementation SharedDevice
static SharedDevice* _instance = nil;
static id<MTLDevice> sharedDevice;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
        NSLog(@"shareInstance");
        sharedDevice = MTLCreateSystemDefaultDevice();
    }) ;
    return _instance ;
}
//+ (id)allocWithZone:(struct _NSZone *)zone {
//    return [SharedDevice shareInstance] ;
//}

- (id)copyWithZone:(NSZone *)zone {
    return [SharedDevice shareInstance] ;//return _instance;
}

-(id) mutablecopyWithZone:(NSZone *)zone {
    return [SharedDevice shareInstance] ;
}
- (id<MTLDevice>)sharedDevice {
    return sharedDevice;
}
@end

@interface MetalView ()
@property (nonatomic, strong) id<MTLBuffer> render_target_vertex;
@property (nonatomic, strong) id<MTLBuffer> render_target_uniform;
@property (nonatomic, strong) id<MTLRenderPipelineState> piplineState;
@end
@implementation MetalView
// MARK: - Brush Textures
- (MLTexture *)makeTextureWithData:(NSData *)data uuid:(nullable NSUUID *)uuid {
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc]initWithDevice:self.device];
    NSError *error;
    id <MTLTexture> texture = [textureLoader newTextureWithData:data options:@{MTKTextureLoaderOptionSRGB : @(NO)} error:&error];
    if (error) {
        return nil;
    }
    return [[MLTexture alloc]initWithId:[NSUUID UUID] texture:texture];
}
- (MLTexture *)makeTextureWithFile:(NSURL *)url uuid:(nullable NSUUID *)uuid {
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    return [self makeTextureWithData:data uuid:uuid];
}
// MARK: - Functions
- (void)claerDisplay:(BOOL)display {
    [self.screenTarget clear];
    if (display) {
        [self setNeedsDisplay];
    }
}
// MARK: - Render
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.screenTarget updateBufferWithSize:self.drawableSize];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    UIColor *color = backgroundColor ? backgroundColor : [UIColor whiteColor];
    self.clearColor = [color toClearColor];
    
}

// MARK: - Setup
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device {
    self = [super initWithFrame:frameRect device:device];
    if (self) {
        [self setup];
    }
    return self;
}
#if !(TARGET_IPHONE_SIMULATOR)
- (CAMetalLayer *)metalLayer {
    if (![self.layer isKindOfClass:[CAMetalLayer class]]) {
        [NSException exceptionWithName:@"Metal" reason:@"Metal initialize failed" userInfo:nil];
    }
    return (CAMetalLayer *)self.layer;
}
#endif
- (void)setup {
   
    self.device = [SharedDevice shareInstance].sharedDevice;
    self.opaque = NO;
    
    self.screenTarget = [[RenderTarget alloc]initWithSize:self.drawableSize pixelFormat:self.colorPixelFormat device:self.device];
    self.commandQueue = [self.device newCommandQueue];
    [self setupTargetUniforms];
    [self setupPiplineState];
}
- (void)setupPiplineState {
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    id<MTLFunction> vertex_func = [library newFunctionWithName:@"vertex_render_target"];
    id<MTLFunction> fragment_func = [library newFunctionWithName:@"fragment_render_target"];
    MTLRenderPipelineDescriptor *rpd = [MTLRenderPipelineDescriptor new];
    rpd.vertexFunction = vertex_func;
    rpd.fragmentFunction = fragment_func;
    rpd.colorAttachments[0].pixelFormat = self.colorPixelFormat;
    NSError *error;
    self.piplineState = [self.device newRenderPipelineStateWithDescriptor:rpd error:&error];
    if (error) {
        [NSException exceptionWithName:@"Metal" reason:@"Metal initialize failed" userInfo:error.userInfo];
    }
}
- (void)setupTargetUniforms {
    CGSize size = self.drawableSize;
    CGFloat width = size.width, height = size.height;
    Vertex vertices[] = {
        { .position = {0, 0, 0, 1}, .textCoord = {0, 0} },
        { .position = {width, 0, 0, 1 }, .textCoord = {1, 0} },
        { .position = {0, height, 0, 1}, .textCoord = {0, 1} },
        { .position = {width, height, 0, 1}, .textCoord = {1, 1} }
    };
    self.render_target_vertex = [self.device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceCPUCacheModeWriteCombined];
    
    Matrix *matrix = [Matrix identity];
    [matrix scalingWithX:2 / size.width y:-2 / size.height z:1];
    [matrix translationWithX:-1 y:1 z:0];
    self.render_target_uniform = [self.device newBufferWithBytes:matrix.values length:sizeof(float) * 16 options:MTLResourceCPUCacheModeDefaultCache];
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    #if !(TARGET_IPHONE_SIMULATOR)
    id<MTLTexture> texture = self.screenTarget.texture;
    id <CAMetalDrawable> drawable = self.currentDrawable;
    if (!texture || !drawable) {
        return;
    }
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    MTLRenderPassColorAttachmentDescriptor *attachment = renderPassDescriptor.colorAttachments[0];
    attachment.clearColor = self.clearColor;
    attachment.texture = drawable.texture;
    attachment.loadAction = MTLLoadActionClear;
    attachment.storeAction = MTLStoreActionStore;
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [commandEncoder setRenderPipelineState:self.piplineState];
    [commandEncoder setVertexBuffer:self.render_target_vertex offset:0 atIndex:0];
    [commandEncoder setVertexBuffer:self.render_target_uniform offset:0 atIndex:1];
    [commandEncoder setFragmentTexture:texture atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [commandEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
    #endif
}
@end
