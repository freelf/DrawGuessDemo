//
//  PaintingGestureRecognizer.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "PaintingGestureRecognizer.h"
#import "Maths.h"

@interface PaintingGestureRecognizer ()
@property (nonatomic, weak) UIView *targetView;
@end
@implementation PaintingGestureRecognizer
+ (instancetype)addToTarget:(UIView *)target action:(SEL)action {
    PaintingGestureRecognizer *ges = [[PaintingGestureRecognizer alloc]initTargetView:target action:action];
    [target addGestureRecognizer:ges];
    return ges;
}
- (instancetype)initTargetView:(UIView *)targetView action:(SEL)action {
    self = [super initWithTarget:targetView action:action];
    if (self) {
        self.acturalBeginLocation = CGPointZero;
        self.force = 1;
        self.forceEnabled = YES;
        self.targetView = targetView;
        self.maximumNumberOfTouches = 1;
    }
    return self;
}
- (void)updateForceFromTouches:(NSSet<UITouch *>*)touches {
    if (touches.count <= 0) {
        return;
    }
    UITouch *touch = [touches allObjects][0];
    if (self.forceEnabled && touch.force >= 0) {
        self.force = touch.force / 3;
        return;
    }
    CGPoint vel = [self velocityInView:self.targetView];
    CGFloat length = [CGPointExtension distanceOfOnePoint:vel toOtherPoint:CGPointZero];
    length = MIN(length, 5000);
    length = MAX(100, length);
    self.force = sqrt(1000 / length);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count > 0) {
        UITouch *touch = [touches allObjects][0];
        self.acturalBeginLocation = [touch locationInView:self.targetView];
    }
    [self updateForceFromTouches:touches];
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateForceFromTouches:touches];
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateForceFromTouches:touches];
    [super touchesEnded:touches withEvent:event];
}
@end
