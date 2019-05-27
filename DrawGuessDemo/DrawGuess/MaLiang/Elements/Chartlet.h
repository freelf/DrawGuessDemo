//
//  Chartlet.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CanvasData.h"
NS_ASSUME_NONNULL_BEGIN

@interface Chartlet : NSObject<CanvasElement>
{
    NSInteger _index;
}
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSUUID *textureId;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, weak) Canvas *canvas;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLBuffer> vertex_buffer;

- (instancetype)initWithCenter:(CGPoint)center size:(CGSize)size textureId:(nullable NSUUID *)textureId angle:(CGFloat)angle canvas:(Canvas *)canvas;
@end

NS_ASSUME_NONNULL_END
