//
//  ChangeCanvasColor.m
//  Undercover
//
//  Created by Beyond on 2019/5/17.
//  Copyright © 2019 Moqipobing. All rights reserved.
//

#import "ChangeCanvasColor.h"

@implementation ChangeCanvasColor
- (void)setIndex:(NSInteger)index {
    _index = index;
}
- (NSInteger)index {
    return  _index;
}
- (instancetype)initWithCanvasColor:(UIColor *)color canvas:(Canvas *)canvas {
    self = [super init];
    if (self) {
        self.index = 0;
        self.canvasColor = color;
        self.canvas = canvas;
    }
    return self;
}
- (void)drawSelfOnTarget:(RenderTarget *)target {
    // 这里不做任何处理
}
@end
