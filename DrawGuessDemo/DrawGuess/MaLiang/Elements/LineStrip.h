//
//  LineStrip.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLColor.h"
#import "MLLine.h"
#import "RenderTarget.h"
#import "Brush.h"
#import "CanvasData.h"
NS_ASSUME_NONNULL_BEGIN

@interface LineStrip : NSObject<CanvasElement>
{
    NSInteger _index;
}

@property (nonatomic, copy) NSString *brushName;
@property (nonatomic, strong) MLColor *color;

@property (nonatomic, strong, readonly) NSMutableArray<MLLine *> *lines;
@property (nonatomic, weak) Brush *brush;
@property (nonatomic, assign, readonly) NSInteger vertexCount;

- (instancetype)initLines:(NSArray<MLLine *> *)lines brush:(Brush *)brush;
- (void)appendLines:(NSArray<MLLine *> *)lines;
- (id<MTLBuffer>)retrieveBuffersRotation:(Rotation)rotation;

@end

NS_ASSUME_NONNULL_END
