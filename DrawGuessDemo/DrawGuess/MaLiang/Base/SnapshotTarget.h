//
//  SnapshotTarget.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "RenderTarget.h"
#import "Canvas.h"

NS_ASSUME_NONNULL_BEGIN

@interface SnapshotTarget : RenderTarget
- (instancetype)initWithCanvas:(Canvas *)canvas;
- (UIImage *)getImage;
- (CIImage *)getCIImage;
- (CGImageRef)getCGImage;

@end

NS_ASSUME_NONNULL_END
