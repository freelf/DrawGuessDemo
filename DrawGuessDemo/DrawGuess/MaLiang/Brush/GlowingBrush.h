//
//  GlowingBrush.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Brush.h"

NS_ASSUME_NONNULL_BEGIN

@interface GlowingBrush : Brush
@property (nonatomic, assign) CGFloat coreProportion;
@property (nonatomic, strong) UIColor *coreColor;

@end

NS_ASSUME_NONNULL_END
