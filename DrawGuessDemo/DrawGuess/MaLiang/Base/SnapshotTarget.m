//
//  SnapshotTarget.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "SnapshotTarget.h"
#import "MLTexture.h"

@interface SnapshotTarget ()
@property (nonatomic, weak) Canvas *canvas;
@end
@implementation SnapshotTarget
- (instancetype)initWithCanvas:(Canvas *)canvas {
    self = [super init];
    if (self) {
        self.canvas = canvas;
        self = [super initWithSize:self.canvas.drawableSize pixelFormat:canvas.colorPixelFormat device:canvas.device];
    }
    return self;
}
- (UIImage *)getImage {
//    [self syncContent];
    return [MTLTextureExtension toUIImageWithTexture:self.texture];
}
- (CIImage *)getCIImage {
    [self syncContent];
    return [MTLTextureExtension toCIImageWithTexture:self.texture];
}
- (CGImageRef)getCGImage {
    [self syncContent];
    return [MTLTextureExtension toCGImageWithTexture:self.texture];
}

- (void)syncContent {
    [self.canvas redrawOnTarget:self];
    [self commitCommands];
}
@end
