//
//  Printer.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Printer.h"

@implementation Printer
- (id<MTLFunction>)makeShaderVertexFunctionFromLibrary:(id<MTLLibrary>)library {
    return [library newFunctionWithName:@"vertex_printer_func"];
}
- (id<MTLFunction>)makeShaderFragmentFunctionFromLibrary:(id<MTLLibrary>)library {
    return [library newFunctionWithName:@"fragment_render_target"];
}
- (void)setupBlendOptionForAttachment:(MTLRenderPipelineColorAttachmentDescriptor *)attachment {
    attachment.blendingEnabled = YES;
    
    attachment.rgbBlendOperation = MTLBlendOperationAdd;
    attachment.sourceRGBBlendFactor = MTLBlendFactorOne;
    attachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    attachment.alphaBlendOperation = MTLBlendOperationAdd;
    attachment.sourceAlphaBlendFactor = MTLBlendFactorOne;
    attachment.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
}
- (void)renderChartlet:(Chartlet *)chartlet onRenderTarget:(RenderTarget *)target {
    RenderTarget *tempTarget = self.target.screenTarget;
    if (target) {
        tempTarget = target;
    }
    if (!tempTarget) {
        return;
    }
    [target prepareForDraw];
    id<MTLRenderCommandEncoder> commandEncoder = [target makeCommandEncoder];
    [commandEncoder setRenderPipelineState:self.piplineState];
    id<MTLTexture> texture = chartlet.texture ? chartlet.texture : [self.target findTextureByUUID:chartlet.textureId].texture;
    id<MTLBuffer> vertex_buffer = chartlet.vertex_buffer;
    if (vertex_buffer && texture) {
        [commandEncoder setVertexBuffer:vertex_buffer offset:0 atIndex:0];
        [commandEncoder setVertexBuffer:target.uniform_buffer offset:0 atIndex:1];
        [commandEncoder setVertexBuffer:target.transform_buffer offset:0 atIndex:2];
        [commandEncoder setFragmentTexture:texture atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    }
    [commandEncoder endEncoding];
}
@end
