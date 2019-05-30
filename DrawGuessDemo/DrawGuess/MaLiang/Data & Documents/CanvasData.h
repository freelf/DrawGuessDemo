//
//  CanvasData.h
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RenderTarget.h"
#import "MLLine.h"
#import "Brush.h"
@class ChangeCanvasColor;
@class Chartlet;
@class Canvas;
NS_ASSUME_NONNULL_BEGIN
@protocol CanvasElement <NSObject>
@property (nonatomic, assign) NSInteger index;

- (void)drawSelfOnTarget:(RenderTarget *)target;

@end

@interface ClearAction : NSObject<CanvasElement>
{
    NSInteger _index;
}

@end

@class CanvasData;
typedef void  (^EventHandler)(CanvasData *);
@interface CanvasData : NSObject
@property (nonatomic, weak) Canvas *canvas;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<id<CanvasElement>>*> *clearedElements;
@property (nonatomic, strong, readonly) NSMutableArray<ChangeCanvasColor *> *changCanvasColorActions;
@property (nonatomic, strong) NSMutableArray<id<CanvasElement>> *elements;
@property (nonatomic, strong, readonly) NSArray<id<CanvasElement>> *needDrawElements;
@property (nonatomic, strong, nullable) id<CanvasElement> currentElement;
@property (nonatomic, strong, readonly) NSMutableArray<id<CanvasElement>> *undoArray;
@property (nonatomic, strong, nullable) Chartlet *undoBaseCharlet;
@property (nonatomic, assign) BOOL canRedo;
@property (nonatomic, assign) BOOL canUndo;
@property (nonatomic, assign) NSUInteger canUndoCount;
- (instancetype)initWithCanvas:(Canvas *)canvas;

- (void)appendLines:(NSArray<MLLine *>*)lines withBrush:(Brush*)brush;
- (void)appendChartlet:(Chartlet *)chartlet;
- (void)appendClearAction;
- (void)appendChangeCanvasColorAction:(ChangeCanvasColor *)changeColorElement;
- (void)appendInitialCanvasColor:(ChangeCanvasColor *)initialColorAction;

- (void)finishCurrentElement;

- (BOOL)undo;
- (BOOL)redo;
- (instancetype)onElementBegin:(EventHandler)begin;
- (instancetype)onElementFinish:(EventHandler)finish;
- (instancetype)onRedo:(EventHandler)redo;
- (instancetype)onUndo:(EventHandler)undo;
@end

NS_ASSUME_NONNULL_END
