//
//  WBMetalCanvasView.h
//  Undercover
//
//  Created by Beyond on 2019/5/13.
//  Copyright © 2019 Moqipobing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Canvas.h"
@class WBProgressHUD;
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN  NSString * const WBGameDrawGuessPenBrush;
FOUNDATION_EXTERN  NSString * const WBGameDrawGuessGlowBrush;
FOUNDATION_EXTERN  NSString * const WBGameDrawGuessEraserBrush;
FOUNDATION_EXTERN  NSString * const WBGameDrawGuessOneLineRainbowBrush;
@interface WBMetalCanvasView : UIView
@property (nonatomic, strong, readonly) Canvas *canvas;
@property (nonatomic, assign) BOOL isPainter; // 是否是画的人， 1 是 ， 0 不是
@property (nonatomic, assign) BOOL hasStrokes;
@property (nonatomic, strong, nullable) WBProgressHUD *loadOldStrokHud;
- (void)stopDraw;
- (void)onReceiveDrawCommandInfo:(NSDictionary *)commandInfo;
- (void)clearCanvas;
- (void)refreshCanvas;
@end

NS_ASSUME_NONNULL_END
