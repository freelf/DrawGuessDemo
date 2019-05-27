//
//  WBMetalCanvasView.m
//  Undercover
//
//  Created by Beyond on 2019/5/13.
//  Copyright © 2019 Moqipobing. All rights reserved.
//

#import "WBMetalCanvasView.h"
#import "Canvas.h"
#import "Brush.h"
#import "GlowingBrush.h"
#import "UIColor+Extension.h"
//@import WBProgressHUD;
//@import WBThemeKit;
NSString * const WBGameDrawGuessPenBrush = @"Pen";
NSString * const WBGameDrawGuessGlowBrush = @"Glow";
NSString * const WBGameDrawGuessEraserBrush = @"Eraser";
NSString * const WBGameDrawGuessOneLineRainbowBrush = @"OneLineRainbow";
@interface WBMetalCanvasView ()
<
CanvasAudienceDrawStageDelegate
>
@property (nonatomic, strong, readwrite) Canvas *canvas;
@property (nonatomic, strong) NSArray<Brush *> *brushArray;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *receiveCommandsBufferArray;
@end

@implementation WBMetalCanvasView
// MARK: - Setter & Getter
- (NSMutableArray<NSDictionary *> *)receiveCommandsBufferArray {
    if (!_receiveCommandsBufferArray) {
        _receiveCommandsBufferArray = [NSMutableArray array];
    }
    return _receiveCommandsBufferArray;
}
- (void)setIsPainter:(BOOL)isPainter {
    _isPainter = isPainter;
    if (_isPainter && !self.hasStrokes && self.receiveCommandsBufferArray.count == 0) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
}
// MARK: - Init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCanvas];
    }
    return self;
}
- (void)setupCanvas {
    // 必须使用这个方法初始化，不然渲染通道初始化不了
    self.canvas =[[Canvas alloc]initWithFrame:self.bounds device:nil];
    self.canvas.audienceDrawDelegate = self;
    [self addSubview:self.canvas];
    if (self.superview) {
        self.canvas.stageDelegate = (id<CanvasStageDelegate>)[self superview];
    }
    [self registBrush];
}
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.canvas.stageDelegate = (id<CanvasStageDelegate>)[self superview];
}
- (void)registBrush {
    Brush *pen = [self setupPenBrush];
    Brush *glow = [self setupGlowBrush];
    Brush *eraser = [self setupEarseBrush];
    Brush *oneLineRainbow = [self setupOneLineRainbowBrush];
    self.brushArray = @[pen, glow, eraser, oneLineRainbow];
    [pen use];
}
- (Brush *)setupPenBrush {
    MLTexture *texture = [self.canvas makeTextureWithData:UIImagePNGRepresentation([UIImage imageNamed:@"pen-texture.png"]) uuid:nil];
    Brush *brush = [self.canvas registerBrushWithClassName:@"Brush" name:WBGameDrawGuessPenBrush textureId:texture.uuid];
    brush.opacity = 1;
    brush.pointSize = 1;
    brush.pointStep = 0.5;
    brush.rotation = RotationAhead;
    return brush;
}
- (Brush *)setupGlowBrush {
    MLTexture *texture = [self.canvas makeTextureWithData:UIImagePNGRepresentation([UIImage imageNamed:@"glow.png"]) uuid:nil];
    GlowingBrush *brush = (GlowingBrush *)[self.canvas registerBrushWithClassName:@"GlowingBrush" name:WBGameDrawGuessGlowBrush textureId:texture.uuid];
    brush.opacity = 0.05;
    brush.coreProportion = 0.2;
    brush.pointSize = 20;
    brush.color = [UIColor redColor];
    brush.rotation = RotationAhead;
    return brush;
}
- (Brush *)setupEarseBrush {
    Brush *brush = [self.canvas registerBrushWithClassName:@"Eraser" name:WBGameDrawGuessEraserBrush textureId:nil];
    brush.pointStep = 0.5;
    return brush;
}
- (Brush *)setupOneLineRainbowBrush {
    MLTexture *texture = [self.canvas makeTextureWithData:UIImagePNGRepresentation([UIImage imageNamed:@"pen-texture.png"]) uuid:nil];
    Brush *brush = [self.canvas registerBrushWithClassName:@"Brush" name:WBGameDrawGuessOneLineRainbowBrush textureId:texture.uuid];
    brush.opacity = 1;
    brush.pointSize = 5;
    brush.pointStep = 0.5;
    brush.rotation = RotationAhead;
    return brush;
}
// MARK: - Public Methods
- (void)onReceiveDrawCommandInfo:(NSDictionary *)commandInfo {
    NSArray <NSDictionary *>*array = commandInfo[@"drawStrokes"];  // 画笔list
    dispatch_async(dispatch_get_main_queue(), ^{
        [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!dict) {
                return;
            }
            if (self.receiveCommandsBufferArray.count > 0) {
                [self.receiveCommandsBufferArray addObject:dict];
            } else {
                [self.receiveCommandsBufferArray addObject:dict];
                [self handleDrawCommandInfo:dict];
            }
        }];
    });
}
- (void)clearCanvas {
    [self.canvas clearDisplay:YES];
}
- (void)refreshCanvas {
    // 刷新的情况直接创建一个画布
    [self.canvas removeFromSuperview];
    [self setupCanvas];
}
// MARK: - CanvasAudienceDrawStageDelegate
- (void)canvasAudienceDrawStrokeEnd {
    [self drawNext];
}

// MARK: - Private Methods
- (void)handleDrawCommandInfo:(NSDictionary *)commandInfo {
    NSInteger commandType = [commandInfo[@"type"] integerValue];
    BOOL isDrawCommand = [commandInfo.allKeys containsObject:@"paintType"] && [commandInfo[@"paintType"] integerValue] > 1;
    if (commandType == 1 || commandType == 2 || isDrawCommand) { // 画笔和橡皮
        [self.canvas drawWithReceivePointsInfo:commandInfo];
    } else if (commandType == 3) { // 改变画布颜色
        NSString *colorString = commandInfo[@"color"];
        self.backgroundColor = [UIColor wb_colorWithHex:colorString];
        [self.canvas appendChangeCanvasColorActionWithColor:self.superview.backgroundColor];
        [self drawNext];
    } else if (commandType == 4) { // Undo
        [self.canvas undo];
        [self drawNext];
    } else if (commandType == 5) { // Redo
        [self.canvas redo];
        [self drawNext];
    } else if (commandType == 6) { // 清空画布
        [self.canvas clearDisplay:YES];
        [self drawNext];
    }
}
- (void)drawNext {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.receiveCommandsBufferArray count] > 0) {
            [self.receiveCommandsBufferArray removeObjectAtIndex:0];
            if ([self.receiveCommandsBufferArray count] > 0) {
                NSDictionary *dict = [self.receiveCommandsBufferArray objectAtIndex:0];
                [self handleDrawCommandInfo:dict];
            } else {
                // 绘制结束
                // 这里是为了处理主画人掉线进来点击屏幕出现放射线条的问题，已经画完之后再接受交互
                if (self.isPainter) {
//                    [self redrawFinish];
                }
//                if (self.delegate && [self.delegate respondsToSelector:@selector(drawingViewDrawOver)]) {
//                    [self.delegate drawingViewDrawOver];
//                }
            }
        }
    });
}
//- (void)redrawFinish {
//    if (self.receiveCommandsBufferArray.count == 0) {
//        self.loadOldStrokHud.label.text = @"画作已加载完成~";
//        [self.loadOldStrokHud hideAnimated:YES afterDelay:1];
//        self.userInteractionEnabled = YES;
//        self.loadOldStrokHud = nil;
//    }
//}
- (void)stopDraw {
    [self.canvas stopDraw];
}
@end
