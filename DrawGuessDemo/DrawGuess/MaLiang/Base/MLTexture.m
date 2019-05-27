//
//  MLTexture.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/7.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "MLTexture.h"

@implementation MLTexture
- (instancetype)initWithId:(NSUUID *)uuid texture:(id<MTLTexture>)texture {
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.texture = texture;
    }
    return self;
}
- (CGSize)size {
    CGFloat scaleFactor = [[UIScreen mainScreen] nativeScale];
    return CGSizeMake(self.texture.width / scaleFactor, self.texture.height / scaleFactor);
}
- (BOOL)isEqual:(id)object {
    return [self.uuid.UUIDString isEqualToString:((MLTexture *)object).uuid.UUIDString];
}
- (NSUInteger)hash {
    return self.uuid.UUIDString.hash ^ self.texture.hash;
}
@end
@implementation MTLTextureExtension
+ (CIImage *)toCIImageWithTexture:(id<MTLTexture>)texture {
    CIImage *image = [[CIImage alloc] initWithMTLTexture:texture options:@{kCIImageColorSpace : CFBridgingRelease(CGColorSpaceCreateDeviceRGB())}];
    return [image imageByApplyingOrientation:4];
}
+ (CGImageRef)toCGImageWithTexture:(id<MTLTexture>)texture {
    CIImage *image = [self toCIImageWithTexture:texture];
    if (!image) {
        return nil;
    }
    CIContext *context = [CIContext new];
    CGRect rect = {CGPointZero, image.extent.size};
    return [context createCGImage:image fromRect:rect];
}
+ (UIImage *)toUIImageWithTexture:(id<MTLTexture>)texture {
    CGImageRef image = [self toCGImageWithTexture:texture];
    if (!image) {
        return nil;
    }
    return [UIImage imageWithCGImage:image];
}
+ (NSData *)toBytesWithTexture:(id<MTLTexture>)texture {
    UIImage *image = [self toUIImageWithTexture:texture];
    if (!image) {
        return  nil;
    }
    return UIImagePNGRepresentation(image);
}
@end
