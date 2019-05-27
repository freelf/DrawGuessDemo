//
//  Eraser.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Eraser.h"

@implementation Eraser
- (void)setupBlendOptionForAttachment:(MTLRenderPipelineColorAttachmentDescriptor *)attachment {
    attachment.blendingEnabled = YES;
    attachment.alphaBlendOperation = MTLBlendOperationReverseSubtract;
    attachment.rgbBlendOperation = MTLBlendOperationReverseSubtract;
    attachment.sourceRGBBlendFactor = MTLBlendFactorZero;
    attachment.sourceAlphaBlendFactor = MTLBlendFactorOne;
    attachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    attachment.destinationAlphaBlendFactor = MTLBlendFactorOne;
}
@end
