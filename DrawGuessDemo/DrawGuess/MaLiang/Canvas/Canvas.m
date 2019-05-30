//
//  Canvas.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "Canvas.h"
#import "BezierGenerator.h"
#import "Brush.h"
#import "PaintingGestureRecognizer.h"
#import "Printer.h"
#import "CanvasData.h"
#import "Maths.h"
#import "LineStrip.h"
#import "WBMetalCanvasView.h"
#import "ChangeCanvasColor.h"
#import "SnapshotTarget.h"
#import "UIColor+Extension.h"
//@import libextobjc;

//@import WBThemeKit;

@interface Canvas ()
@property (nonatomic, strong, readwrite) Printer *printer;
@property (nonatomic, strong, readwrite) NSMutableArray<MLTexture *> *textures;
@property (nonatomic, strong, readwrite) NSMutableArray<Brush *> *registeredBrushes;
@property (nonatomic, strong) BezierGenerator *bezierGenerator;
@property (nonatomic, assign) Pan lastRenderedPan;
@property (nonatomic, assign) BOOL isSetLastRenderedPan;
@property (nonatomic, strong, readwrite) CanvasData *data;
@property (nonatomic, strong) NSMutableArray *pointsArray;
@property (nonatomic, strong) NSArray<UIColor *> *colorsArray;
@property (nonatomic, assign) BOOL watchPersonStopDraw;
@end

@implementation Canvas
@synthesize scale = _scale;
@synthesize forceEnable = _forceEnable;
@synthesize zoom = _zoom;
@synthesize contentOffset = _contentOffset;
- (NSMutableArray *)pointsArray {
    if (!_pointsArray) {
        _pointsArray = [NSMutableArray array];
    }
    return _pointsArray;
}
- (Brush *)registerBrushWithClassName:(NSString *)className name:(NSString *)name fromData:(NSData *)data {
    MLTexture *texture = [self makeTextureWithData:data uuid:nil];
    Brush *brush = [[NSClassFromString(className) alloc]initWithName:name textureId:texture.uuid target:self];
    [self.registeredBrushes addObject:brush];
    return brush;
}
- (Brush *)registerBrushWithClassName:(NSString *)className name:(NSString *)name fromFileUrl:(NSURL *)fileUrl {
    NSData *data = [[NSData alloc]initWithContentsOfURL:fileUrl];
    return [self registerBrushWithClassName:className name:name fromData:data];
}
- (Brush *)registerBrushWithClassName:(NSString *)className name:(NSString *)name textureId:(NSUUID *)textureId {
    Brush *brush = [[NSClassFromString(className) alloc]initWithName:name textureId:textureId target:self];
    [self.registeredBrushes addObject:brush];
    return brush;
}
- (Brush *)findBrushByName:(NSString *)name {
    Brush *findBrush = nil;
    for (Brush *brush in self.registeredBrushes) {
        if ([brush.name isEqualToString: name]) {
            findBrush = brush;
            break;
        }
    }
    return findBrush ? findBrush : self.defaultBrush;
}
- (MLTexture *)makeTextureWithData:(NSData *)data uuid:(nullable NSUUID *)uuid {
    if (uuid) {
        MLTexture *texture = [self findTextureByUUID:uuid];
        if (texture) {
            return texture;
        }
    }
    MLTexture *texture = [super makeTextureWithData:data uuid:uuid];
    [self.textures addObject:texture];
    return texture;
}
- (MLTexture *)makeTextureWithData:(NSData *)data {
    MLTexture *texture = [super makeTextureWithData:data uuid:nil];
    return texture;
}
- (MLTexture *)findTextureByUUID:(NSUUID *)uuid {
    MLTexture *findTexture = nil;
    for (MLTexture *texture in self.textures) {
        if ([texture.uuid.UUIDString isEqualToString:uuid.UUIDString]) {
            findTexture = texture;
            break;
        }
    }
    return findTexture;
}
- (void)setLastRenderedPan:(Pan)lastRenderedPan {
    _lastRenderedPan = lastRenderedPan;
    self.isSetLastRenderedPan = YES;
}
- (void)setup {
    [super setup];
    self.screenTarget = [[SnapshotTarget alloc]initWithCanvas:self];
    self.watchPersonStopDraw = NO;
    self.framebufferOnly = NO;
    self.colorsArray = @[[UIColor wb_colorWithHex:@"#FF0705"],
                         [UIColor wb_colorWithHex:@"#FFB300"],
                         [UIColor wb_colorWithHex:@"#FDE325"],
                         [UIColor wb_colorWithHex:@"#5BFE2A"],
                         [UIColor wb_colorWithHex:@"#2AE7FC"],
                         [UIColor wb_colorWithHex:@"#2D6AFF"],
                         [UIColor wb_colorWithHex:@"#C93CFF"],
                         [UIColor wb_colorWithHex:@"#FE40B8"]]; // 彩虹笔颜色数组
    
    self.isSetLastRenderedPan = NO;
    self.bezierGenerator = [BezierGenerator new];
    self.registeredBrushes = @[].mutableCopy;
    self.textures = @[].mutableCopy;
    self.defaultBrush = [[Brush alloc]initWithName:@"maliang.default" textureId:nil target:self];
    self.currentBrush = self.defaultBrush;
    
    self.printer = [[Printer alloc]initWithName:@"maliang.printer" textureId:nil target:self];
    self.data = [[CanvasData alloc]initWithCanvas:self];
    self.data.canvas = self;
    ChangeCanvasColor *initialColorAction = [[ChangeCanvasColor alloc]initWithCanvasColor:[UIColor colorWithRed:0.97 green:0.98 blue:0.88 alpha:1.00] canvas:self];
    [self.data appendInitialCanvasColor:initialColorAction];
    self.data.canUndoCount = 100;
    [self setupGestureRecognizers];
    self.forceEnable = NO;
}
// MARK: - Public Method
- (void)setupGestureRecognizers {
    self.paintingGesture = [PaintingGestureRecognizer addToTarget:self action:@selector(handlePaintingGesture:)];
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self.tapGesture];
}
- (void)changeCanvasColor:(UIColor *)color {
    if ([self.stageDelegate respondsToSelector:@selector(undoChangeCanvasColor:)]) {
        [self.stageDelegate undoChangeCanvasColor:color];
    }
}
- (UIImage *)snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.contentScaleFactor);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)useDefaultBrush {
    [self.registeredBrushes.firstObject use];
}
- (void)clearDisplay:(BOOL)display {
    [super claerDisplay: display];
    if (display) {
        [self.data appendClearAction];
    }
}
- (void)refresh {
    self.data = [CanvasData new];
    [self clearDisplay:NO];
    [self.registeredBrushes removeAllObjects];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self redrawOnTarget:nil];
}
- (BOOL)undo {
    if (self.data && [self.data undo]) {
        [self redrawOnTarget:nil];
        return YES;
    } else {
        return NO;
    }
}
- (BOOL)redo {
    if (self.data && [self.data redo]) {
        [self redrawOnTarget:nil];
        return YES;
    } else {
        return NO;
    }
}
- (void)redrawOnTarget:(RenderTarget *)target {
    RenderTarget *renderTarget = self.screenTarget;
    if (target) {
        renderTarget = target;
    }
    [renderTarget updateBufferWithSize:self.drawableSize];
    [renderTarget clear];
    if (self.data.undoBaseCharlet) {
        [self renderChartlet:self.data.undoBaseCharlet];
    }
    for (id<CanvasElement> element in self.data.needDrawElements) {
        [element drawSelfOnTarget:renderTarget];
    }
    [renderTarget commitCommands];
}
- (void)pushPoint:(CGPoint)point toBezier:(BezierGenerator *)bezier force:(CGFloat)force isEnd:(BOOL)isEnd {
    NSMutableArray<MLLine *> *lines = @[].mutableCopy;
    NSArray<NSValue *> *vertices = [bezier pushPoint:point];
    if (vertices.count < 2) {
        return;
    }
    Pan defaultPan = {vertices[0].CGPointValue, force};
    Pan lastPan = self.isSetLastRenderedPan ? self.lastRenderedPan : defaultPan;
    CGFloat defaultForce = self.isSetLastRenderedPan ? self.lastRenderedPan.force : force;
    CGFloat deltaForce = (force - defaultForce) / vertices.count;
    for (int i = 1; i < vertices.count; i++) {
        CGPoint p = vertices[i].CGPointValue;
        CGFloat pointStep = self.currentBrush.pointStep;
        if ((isEnd && i == vertices.count - 1) || pointStep <= 1 || (pointStep > 1 && [CGPointExtension distanceOfOnePoint:lastPan.point toOtherPoint:p] >= pointStep)) {
            CGFloat f = lastPan.force + deltaForce;
            Pan pan = {p, f};
            NSArray<MLLine *> *line = [self.currentBrush makeLineFrom:lastPan to:pan];
            [lines addObjectsFromArray:line];
            lastPan = pan;
            self.lastRenderedPan = pan;
        }
    }
    [self renderLines:lines];
}
- (void)renderLines:(NSArray<MLLine *> *)lines {
    if (@available(iOS 11.0, *)) {
        NSLog(@"%ld", [SharedDevice shareInstance].sharedDevice.currentAllocatedSize);
    }
    [self.data appendLines:lines withBrush:self.currentBrush];
    LineStrip *line = [[LineStrip alloc]initLines:lines brush:self.currentBrush];
    [line drawSelfOnTarget:self.screenTarget];
    [self.screenTarget commitCommands];
}
- (void)renderTapAtPoint:(CGPoint)point toPoint:(CGPoint)toPoint {
    Brush *brush = self.currentBrush;
    NSArray<MLLine *> *lines = [brush makeLineFrom:point to:toPoint force:1 uniqueColor:YES];
    [self renderLines:lines];
}
- (void)appendChangeCanvasColorActionWithColor:(UIColor *)color {
    ChangeCanvasColor *changeColorAction = [[ChangeCanvasColor alloc]initWithCanvasColor:color canvas:self];
    [self.data appendChangeCanvasColorAction:changeColorAction];
}
- (void)renderChartletAtPoint:(CGPoint)point size:(CGSize)size textureId:(NSUUID *)textureId rotation:(CGFloat)rotation {
    Chartlet *charlet = [[Chartlet alloc]initWithCenter:point size:size textureId:textureId angle:rotation canvas:self];
//    [self.data appendChartlet:charlet];
    [charlet drawSelfOnTarget:self.screenTarget];
    [self.screenTarget commitCommands];
    [self setNeedsDisplay];
}
- (void)renderChartlet:(Chartlet *)charlet {
    [charlet drawSelfOnTarget:self.screenTarget];
    [self.screenTarget commitCommands];
}
- (void)stopDraw {
    self.watchPersonStopDraw = YES;
}
// MARK: - Action Event
- (void)handlePaintingGesture:(PaintingGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.currentBrush.name isEqualToString:WBGameDrawGuessOneLineRainbowBrush]) {
            self.currentBrush.color = self.colorsArray[0];
        }
        if ([self.stageDelegate respondsToSelector:@selector(canvasDrawDidBegin)]) {
            [self.stageDelegate canvasDrawDidBegin];
        }
        CGPoint acturalBegin = [gesture acturalBeginLocation];
//        [self.data finishCurrentElement];
        Pan lastPan = {acturalBegin, gesture.force};
        self.lastRenderedPan = lastPan;
        [self.bezierGenerator beginWithPoint:acturalBegin];
        [self pushPoint:location toBezier:self.bezierGenerator force:gesture.force isEnd:NO];
        [self.pointsArray addObject:@[@(acturalBegin.x), @(acturalBegin.y)]];
        [self.pointsArray addObject:@[@(location.x), @(location.y)]];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self pushPoint:location toBezier:self.bezierGenerator force:gesture.force isEnd:NO];
        [self.pointsArray addObject:@[@(location.x), @(location.y)]];
        if ([self.currentBrush.name isEqualToString:WBGameDrawGuessOneLineRainbowBrush]) {
            if (self.pointsArray.count % 20 == 0) {
                NSInteger index = (self.pointsArray.count / 20) % 7;
                self.currentBrush.color = self.colorsArray[index];
            }
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        NSInteger count = self.bezierGenerator.points.count;
        if (count < 3) {
            [self renderTapAtPoint:self.bezierGenerator.points.firstObject.CGPointValue toPoint:self.bezierGenerator.points.lastObject.CGPointValue];
        } else {
            [self pushPoint:location toBezier:self.bezierGenerator force:gesture.force isEnd:YES];
            [self.pointsArray addObject:@[@(location.x), @(location.y)]];
            if ([self.currentBrush.name isEqualToString:WBGameDrawGuessOneLineRainbowBrush]) {
                if (self.pointsArray.count % 20 == 0) {
                    NSInteger index = (self.pointsArray.count / 20) % 7;
                    self.currentBrush.color = self.colorsArray[index];
                }
            }
        }
        [self.bezierGenerator finish];
        self.isSetLastRenderedPan = NO;
        Pan pan = {location, gesture.force};
        NSArray<MLLine *> *unfishedLines = [self.currentBrush finishLineStripAtEnd:pan];
        if (unfishedLines.count > 0) {
            [self renderLines:unfishedLines];
        }
        //        @weakify(self)
        //        [self.screenTarget.commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        //            @strongify(self)
        [self.data finishCurrentElement];
        //        }];
        [self strokeDrawEndWithPoints:self.pointsArray];
        [self.pointsArray removeAllObjects];
    }
}
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if ([self.stageDelegate respondsToSelector:@selector(canvasDrawDidBegin)]) {
            [self.stageDelegate canvasDrawDidBegin];
        }
        CGPoint location = [gesture locationInView:self];
        int i = 0;
        while (i < 3) {
            [self renderTapAtPoint:location toPoint:location];
            i++;
        }
        Pan pan = {location, self.currentBrush.forceOnTap};
        NSArray<MLLine *> *unfishedLines = [self.currentBrush finishLineStripAtEnd:pan];
        if (unfishedLines.count > 0) {
            [self renderLines:unfishedLines];
        }
        //        @weakify(self)
        //        [self.screenTarget.commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        //            @strongify(self)
        [self.data finishCurrentElement];
        //        }];
        
    }
}
- (void)strokeDrawEndWithPoints:(NSArray *)pointsArray {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    CGFloat pointSize = self.currentBrush.pointSize;
    NSNumber *number = [NSNumber numberWithDouble:pointSize];
    NSInteger paintType = 1;
    if ([self.currentBrush.name isEqualToString:WBGameDrawGuessPenBrush]) {
        paintType = 1;
    } else if ([self.currentBrush.name isEqualToString:WBGameDrawGuessEraserBrush]) {
        paintType = 2;
    } else if ([self.currentBrush.name isEqualToString:WBGameDrawGuessGlowBrush]) {
        paintType = 3;
    } else if ([self.currentBrush.name isEqualToString:WBGameDrawGuessOneLineRainbowBrush]) {
        paintType = 4;
    }
    dict[@"linewidth"] = number;
    dict[@"type"]      = @(paintType > 2 ? 1 : paintType); // 兼容老版本
    dict[@"width"]     = @(self.bounds.size.width);
    dict[@"path"]      = pointsArray;
    dict[@"paintType"] = @(paintType);
    if (CGColorEqualToColor(self.currentBrush.color.CGColor, [UIColor clearColor].CGColor)) {
        dict[@"color"] = @"";
    } else {
        dict[@"color"] = [self HexWithColor:self.currentBrush.color];
    }
    if ([self.stageDelegate respondsToSelector:@selector(canvasDrawStrokeEndWithStrokeInfo:)]) {
        [self.stageDelegate canvasDrawStrokeEndWithStrokeInfo:dict];
    }
}
- (NSString *)HexWithColor:(UIColor *)color
{
    uint hex;
    CGFloat red, green, blue, alpha;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        [color getWhite:&red alpha:&alpha];
        green = red;
        blue = red;
    }
    red = roundf(red * 255.f);
    green = roundf(green * 255.f);
    blue = roundf(blue * 255.f);
    alpha = roundf(alpha * 255.f);
    hex =  ((uint)red << 16) | ((uint)green << 8) | ((uint)blue);
    return [NSString stringWithFormat:@"#%06x", hex];
}

// MARK: - Draw With Receive Points
- (void)drawWithReceivePointsInfo:(NSDictionary *)pointsInfo {
    NSInteger type;
    if ([pointsInfo.allKeys containsObject:@"paintType"]) {
        type = [pointsInfo[@"paintType"] integerValue];
    } else {
        type = [pointsInfo[@"type"] integerValue];
    }
    NSArray <NSArray *>*pathList = pointsInfo[@"path"];
    Brush *brush = [self chooseBrushWithType:type];
    if (!brush) {
        return;
    }
    [brush use];
    NSString *color     = pointsInfo[@"color"];
    NSNumber *linewidth = pointsInfo[@"linewidth"];
    NSNumber *width     = pointsInfo[@"width"];
    
    CGFloat remoteScreenRatio = 1; // 适配不同屏幕
    if ([width isKindOfClass:[NSNumber class]]) {
        remoteScreenRatio = width.floatValue / self.frame.size.width;
    }
    CGFloat pointSize = linewidth.floatValue / remoteScreenRatio;
    UIColor *brushColor = [UIColor wb_colorWithHex:color];
    if (type == 1 || type == 2) {
        brush.pointSize = pointSize;
        brush.color = brushColor;
    } else if (type == 3) {
        brush.color = brushColor;
    } else if (type == 4) {
        brush.color = self.colorsArray[0];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (pathList.count == 1) { // Tap事件导致的绘制
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *pointArray = pathList.firstObject;
                CGPoint location = [self parsePointWithArray:pointArray screenRatio:remoteScreenRatio];
                [self renderTapAtPoint:location toPoint:location];
                Pan pan = {location, self.currentBrush.forceOnTap};
                NSArray<MLLine *> *unfishedLines = [self.currentBrush finishLineStripAtEnd:pan];
                if (unfishedLines.count > 0) {
                    [self renderLines:unfishedLines];
                }
//                @weakify(self)
//                [self.screenTarget.commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
//                    @strongify(self)
                    [self.data finishCurrentElement];
//                }];
            });
        } else if (pathList.count < 3) { // 只添加了前两个点，需要模拟滑动特殊处理
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *firstPointArray = pathList.firstObject;
                NSArray *lastPointArray = pathList.lastObject;
                CGPoint firstPoint = [self parsePointWithArray:firstPointArray screenRatio:remoteScreenRatio];
                CGPoint lastPoint = [self parsePointWithArray:lastPointArray screenRatio:remoteScreenRatio];
//                [self.data finishCurrentElement];
                Pan lastPan = {firstPoint, 1};
                self.lastRenderedPan = lastPan;
                [self.bezierGenerator beginWithPoint:firstPoint];
                
                [self pushPoint:lastPoint toBezier:self.bezierGenerator force:1 isEnd:NO];
                
                NSInteger count = self.bezierGenerator.points.count;
                if (count < 3) {
                    [self renderTapAtPoint:self.bezierGenerator.points.firstObject.CGPointValue toPoint:self.bezierGenerator.points.lastObject.CGPointValue];
                }
                [self.bezierGenerator finish];
                self.isSetLastRenderedPan = NO;
                Pan pan = {lastPoint, 1};
                NSArray<MLLine *> *unfishedLines = [self.currentBrush finishLineStripAtEnd:pan];
                if (unfishedLines.count > 0) {
                    [self renderLines:unfishedLines];
                }
//                @weakify(self)
//                [self.screenTarget.commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
//                    @strongify(self)
                    [self.data finishCurrentElement];
//                }];
                if (self.audienceDrawDelegate) {
                    [self.audienceDrawDelegate canvasAudienceDrawStrokeEnd];
                }
            });
        } else {
            for (NSInteger idx = 0; idx < pathList.count; idx++) {
                if (self.watchPersonStopDraw) {
                    break;
                }
                NSArray *pointArray = pathList[idx];
                [NSThread sleepForTimeInterval:0.003125];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.currentBrush.name isEqualToString:WBGameDrawGuessOneLineRainbowBrush]) {
                        if (idx % 20 == 0) {
                            NSInteger index = (idx / 20) % 7;
                            self.currentBrush.color = self.colorsArray[index];
                        }
                    }
                    CGPoint point = [self parsePointWithArray:pointArray screenRatio:remoteScreenRatio];
                    if (idx == 0) {
//                        [self.data finishCurrentElement];
                        Pan lastPan = {point, 1};
                        self.lastRenderedPan = lastPan;
                        [self.bezierGenerator beginWithPoint:point];
                    } else if (idx == pathList.count - 1) {
                        NSInteger count = self.bezierGenerator.points.count;
                        if (count < 3) {
                            [self renderTapAtPoint:self.bezierGenerator.points.firstObject.CGPointValue toPoint:self.bezierGenerator.points.lastObject.CGPointValue];
                        } else {
                            [self pushPoint:point toBezier:self.bezierGenerator force:1 isEnd:YES];
                        }
                        [self.bezierGenerator finish];
                        self.isSetLastRenderedPan = NO;
                        Pan pan = {point, 1};
                        NSArray<MLLine *> *unfishedLines = [self.currentBrush finishLineStripAtEnd:pan];
                        if (unfishedLines.count > 0) {
                            [self renderLines:unfishedLines];
                        }
//                        @weakify(self)
//                        [self.screenTarget.commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
//                            @strongify(self)
                            [self.data finishCurrentElement];
//                        }];
                        if (self.audienceDrawDelegate) {
                            [self.audienceDrawDelegate canvasAudienceDrawStrokeEnd];
                        }
                    } else {
                        if (self.watchPersonStopDraw) {
                            return;
                        }
                        [self pushPoint:point toBezier:self.bezierGenerator force:1 isEnd:NO];
                    }
                });
            }
        }
    });
    
}
/** 把 网络端传过来的 需要展示的 点的坐标数组 转换为适应自己屏幕尺寸的 CGPoint, 用来绘画  */
- (CGPoint)parsePointWithArray:(NSArray *)pointArray screenRatio:(CGFloat)ratio {
    float x = [[pointArray objectAtIndex:0] floatValue];
    float y = [[pointArray objectAtIndex:1] floatValue];
    CGPoint point;
    if (ratio != 0) {
        point = CGPointMake(x / ratio, y / ratio);
    } else {
        point = CGPointMake(0, 0);
    }
    return point;
}
- (Brush *)chooseBrushWithType:(NSInteger)type {
    if (type == 1 ) {
        return [self findBrushByName:WBGameDrawGuessPenBrush];
    } else if (type == 2) {
        return [self findBrushByName:WBGameDrawGuessEraserBrush];
    } else if (type == 3) {
        return [self findBrushByName:WBGameDrawGuessGlowBrush];
    } else if (type == 4) {
        return [self findBrushByName:WBGameDrawGuessOneLineRainbowBrush];
    } else {
        return nil;
    }
}
// MARK: - Setter & Getter
- (void)setCurrentBrush:(Brush *)currentBrush {
    if (_currentBrush == currentBrush) {
        return;
    }
    if (currentBrush == [self findBrushByName:WBGameDrawGuessEraserBrush]) {
        self.beforeEraserBrush = _currentBrush;
    } else {
        self.beforeEraserBrush = currentBrush;
    }
    _currentBrush = currentBrush;
    
}
- (void)setForceEnable:(BOOL)forceEnable {
    _forceEnable = forceEnable;
    self.paintingGesture.forceEnabled = forceEnable;
}
- (BOOL)forceEnable {
    return self.paintingGesture.forceEnabled;
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    self.screenTarget.scale = scale;
}
- (CGFloat)scale {
    return self.screenTarget.scale;
}
- (void)setZoom:(CGFloat)zoom {
    _zoom = zoom;
    self.screenTarget.zoom = zoom;
}
- (CGFloat)zoom {
    return self.screenTarget.zoom;
}
- (void)setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;
    self.screenTarget.contentOffset = contentOffset;
}
- (CGPoint)contentOffset {
    return self.screenTarget.contentOffset;
}
@end
