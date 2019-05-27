//
//  MetalView.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderTarget.h"
#import "MLTexture.h"
@import MetalKit;
@import QuartzCore;

NS_ASSUME_NONNULL_BEGIN
@interface SharedDevice : NSObject
+ (instancetype)shareInstance;
- (id<MTLDevice>)sharedDevice;
@end

@interface MetalView : MTKView
@property (nonatomic, strong) RenderTarget *screenTarget;
@property (nonatomic, strong, nullable) id<MTLCommandQueue> commandQueue;

- (void)setup;
- (void)claerDisplay:(BOOL)display;
- (MLTexture *)makeTextureWithData:(NSData *)data uuid:(nullable NSUUID *)uuid;
- (MLTexture *)makeTextureWithFile:(NSURL *)url uuid:(nullable NSUUID *)uuid;
@end

NS_ASSUME_NONNULL_END
