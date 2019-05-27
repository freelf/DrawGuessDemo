//
//  Printer.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Brush.h"
#import "Chartlet.h"
NS_ASSUME_NONNULL_BEGIN

@interface Printer : Brush
- (void)renderChartlet:(Chartlet *)chartlet onRenderTarget:(RenderTarget *)target;
@end

NS_ASSUME_NONNULL_END
