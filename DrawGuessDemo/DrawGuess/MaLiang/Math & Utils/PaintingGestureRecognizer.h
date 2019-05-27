//
//  PaintingGestureRecognizer.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaintingGestureRecognizer : UIPanGestureRecognizer
+ (instancetype)addToTarget:(UIView *)target action:(SEL)action;
- (instancetype)initTargetView:(UIView *)targetView action:(SEL)action;
@property (nonatomic, assign) CGFloat force;
@property (nonatomic, assign) BOOL forceEnabled;
@property (nonatomic, assign) CGPoint acturalBeginLocation;
@end

NS_ASSUME_NONNULL_END
