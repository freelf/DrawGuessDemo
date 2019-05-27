//
//  MLTexture.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Metal;
@import UIKit;
NS_ASSUME_NONNULL_BEGIN

@interface MLTexture : NSObject
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, assign) CGSize size;
- (instancetype)initWithId:(NSUUID *)uuid texture:(id<MTLTexture>)texture;
@end

@interface MTLTextureExtension : NSObject
+ (CIImage *)toCIImageWithTexture:(id<MTLTexture>)texture;
+ (CGImageRef)toCGImageWithTexture:(id<MTLTexture>)texture;
+ (UIImage *)toUIImageWithTexture:(id<MTLTexture>)texture;
+ (NSData *)toBytesWithTexture:(id<MTLTexture>)texture;
@end
NS_ASSUME_NONNULL_END
