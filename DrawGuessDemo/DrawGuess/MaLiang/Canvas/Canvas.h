//
//  Canvas.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/8.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "MetalView.h"
#import "MLTexture.h"
@class PaintingGestureRecognizer;
@class Printer;
@class Brush;
@class MLLine;
@class CanvasData;
NS_ASSUME_NONNULL_BEGIN
@class Canvas;
@protocol CanvasStageDelegate <NSObject>
- (void)canvasDrawDidBegin;
- (void)canvasDrawStrokeEndWithStrokeInfo:(NSDictionary *)strokeInfo;
- (void)undoChangeCanvasColor:(UIColor *)color;
@end

@protocol CanvasAudienceDrawStageDelegate <NSObject>
- (void)canvasAudienceDrawStrokeEnd;
@end

@interface Canvas : MetalView


@property (nonatomic, assign) CGFloat playBackRate; // 回放速率

@property (nonatomic, strong) Brush *defaultBrush;
@property (nonatomic, strong, readonly) Printer *printer;
@property (nonatomic, strong) Brush *currentBrush;
@property (nonatomic, strong) Brush *beforeEraserBrush; // 橡皮的前一个笔刷

@property (nonatomic, strong, readonly) NSMutableArray<Brush *> *registeredBrushes;
@property (nonatomic, strong, readonly) NSMutableArray<MLTexture *> *textures;

@property (nonatomic, assign) BOOL forceEnable;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) PaintingGestureRecognizer *paintingGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong, readonly) CanvasData *data;

@property (nonatomic, weak) id<CanvasStageDelegate> stageDelegate;
@property (nonatomic, weak) id<CanvasAudienceDrawStageDelegate> audienceDrawDelegate;

- (Brush *)registerBrushWithClassName:(NSString *)className name:(NSString *)name fromData:(NSData *)data;
- (Brush *)registerBrushWithClassName:(NSString *)className name:(NSString *)name fromFileUrl:(NSURL *)fileUrl;
- (Brush *)registerBrushWithClassName:(NSString *)className name:(NSString *)name textureId:(nullable NSUUID *)textureId;
- (Brush *)findBrushByName:(NSString *)name;
- (MLTexture *)findTextureByUUID:(nullable NSUUID *)uuid;
- (MLTexture *)makeTextureWithData:(NSData *)data;
- (void)changeCanvasColor:(UIColor *)color;
- (void)appendChangeCanvasColorActionWithColor:(UIColor *)color;

- (UIImage *)snapshot;

- (void)useDefaultBrush;
- (void)clearDisplay:(BOOL)display;
- (BOOL)undo;
- (BOOL)redo;
- (void)refresh;
- (void)stopDraw;

- (void)redrawOnTarget:(nullable RenderTarget *)target;
- (void)renderLines:(NSArray<MLLine *>*)lines;
- (void)renderTapAtPoint:(CGPoint)point toPoint:(CGPoint)toPoint;
- (void)renderChartletAtPoint:(CGPoint)point size:(CGSize)size textureId:(NSUUID *)textureId rotation:(CGFloat)rotation;

- (void)drawWithReceivePointsInfo:(NSDictionary *)pointsInfo;
@end

NS_ASSUME_NONNULL_END
