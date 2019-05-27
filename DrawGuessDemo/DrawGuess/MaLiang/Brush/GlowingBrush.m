//
//  GlowingBrush.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "GlowingBrush.h"
#import "Maths.h"
@interface GlowingBrush ()
@property (nonatomic, strong) Brush *subBrush;
@property (nonatomic, strong) NSMutableArray<MLLine *> *pendingCoreLines;


@end
@implementation GlowingBrush
// MARK: - Override Property
- (void)setCoreColor:(UIColor *)coreColor {
    _coreColor = coreColor;
    self.subBrush.color = coreColor;
}
- (void)setPointSize:(CGFloat)pointSize {
    [super setPointSize:pointSize];
    self.subBrush.pointSize = pointSize * self.coreProportion;
}
- (void)setPointStep:(CGFloat)pointStep {
    [super setPointStep:pointStep];
    self.subBrush.pointStep = 1;
}
- (void)setForceSensitive:(CGFloat)forceSensitive {
    [super setForceSensitive:forceSensitive];
    self.subBrush.forceSensitive = forceSensitive;
}
- (void)setScaleWithCanvas:(BOOL)scaleWithCanvas {
    [super setScaleWithCanvas:scaleWithCanvas];
    self.subBrush.scaleWithCanvas = scaleWithCanvas;
}
- (void)setForceOnTap:(CGFloat)forceOnTap {
    [super setForceOnTap:forceOnTap];
    self.subBrush.forceOnTap = forceOnTap;
}
- (instancetype)initWithName:(NSString *)name textureId:(NSUUID *)textureId target:(Canvas *)target {
    self = [super initWithName:name textureId:textureId target:target];
    if (self) {
        self.coreProportion = 0.25;
        self.pendingCoreLines = @[].mutableCopy;
        self.subBrush = [[Brush alloc]initWithName:[NSString stringWithFormat:@"%@.sub",self.name] textureId:nil target:target];
        self.coreColor = [UIColor whiteColor];
        self.subBrush.opacity = 1;
    }
    return self;
}
- (NSArray<MLLine *> *)makeLineFrom:(CGPoint)from to:(CGPoint)to force:(CGFloat)force uniqueColor:(BOOL)uniqueColor {
    NSArray<MLLine *> *shadowLines = [super makeLineFrom:from to:to force:force uniqueColor:false];
    CGFloat delta = (self.pointSize * (1 - self.coreProportion)) / 2;
    NSMutableArray<MLLine *> *coreLines = @[].mutableCopy;
    while (self.pendingCoreLines.firstObject && [CGPointExtension distanceOfOnePoint:self.pendingCoreLines.firstObject.begin toOtherPoint:from] >= delta) {
        [coreLines addObject:[self.pendingCoreLines firstObject]];
        [self.pendingCoreLines removeObjectAtIndex:0];
    }
    NSArray<MLLine *> *lines = [self.subBrush makeLineFrom:from to:to force:force uniqueColor:YES];
    [self.pendingCoreLines addObjectsFromArray:lines];
    NSMutableArray *allLinesArray = @[].mutableCopy;
    [allLinesArray addObjectsFromArray:shadowLines];
    [allLinesArray addObjectsFromArray:coreLines];
    return allLinesArray;
}
- (NSArray<MLLine *> *)finishLineStripAtEnd:(Pan)end  {
    NSArray<MLLine *> *lines = [self.pendingCoreLines mutableCopy];
    [self.pendingCoreLines removeAllObjects];
    return lines;
}
@end
