//
//  CanvasData.m
//  MaLiang-OC
//
//  Created by Beyond on 2019/5/9.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "CanvasData.h"
#import "LineStrip.h"
#import "ChangeCanvasColor.h"
#import "Canvas.h"
#import "Chartlet.h"
#import "MLTexture.h"
#import "Canvas.h"
#import "SnapshotTarget.h"
@implementation ClearAction
- (instancetype)init
{
    self = [super init];
    if (self) {
        _index = 0;
    }
    return self;
}
- (void)setIndex:(NSInteger)index {
    _index = index;
}
- (NSInteger)index {
    return _index;
}

- (void)drawSelfOnTarget:(nonnull RenderTarget *)target {
    [target clear];
}

@end
@interface CanvasData ()
@property (nonatomic, assign) NSInteger lastElementIndex;
@property (nonatomic, strong, readwrite) NSMutableArray<id<CanvasElement>> *undoArray;
@property (nonatomic, strong, readwrite) NSMutableArray<ChangeCanvasColor *> *changCanvasColorActions;
@property (nonatomic, copy) EventHandler h_onElementBegin;
@property (nonatomic, copy) EventHandler h_onElementFinish;
@property (nonatomic, copy) EventHandler h_onRedo;
@property (nonatomic, copy) EventHandler h_onUndo;
@property (nonatomic, strong) MLTexture *privateUndoBaseTexture;
@property (nonatomic, strong, readwrite) NSArray<id<CanvasElement>> *needDrawElements;

@property (nonatomic, strong) NSArray<id<MTLTexture>> *reuseTextureArray;
@property (nonatomic, assign) NSUInteger snapshotTimes; // 保存截图的次数
@end
@implementation CanvasData
- (instancetype)initWithCanvas:(Canvas *)canvas {
    self = [super init];
    if (self) {
        self.canvas = canvas;
        self.clearedElements = @[].mutableCopy;
        self.elements = @[].mutableCopy;
        self.needDrawElements = @[].mutableCopy;
        self.undoArray = @[].mutableCopy;
        self.changCanvasColorActions = @[].mutableCopy;
        
        NSMutableArray *array = @[].mutableCopy;
        for (NSUInteger i = 0; i < 2; i++) {
            MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:self.canvas.colorPixelFormat width:self.canvas.drawableSize.width height:self.canvas.drawableSize.height mipmapped:NO];
            textureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
            id<MTLTexture> texture = [self.canvas.device newTextureWithDescriptor:textureDescriptor];
            [array addObject:texture];
        }
        self.reuseTextureArray = array;
    }
    return self;
}

- (void)appendLines:(NSArray<MLLine *> *)lines withBrush:(Brush *)brush {
    if (lines.count <= 0) {
        return;
    }
    if ([self.currentElement isKindOfClass:[LineStrip class]] && ((LineStrip *)self.currentElement).brush == brush) {
        [((LineStrip *)self.currentElement) appendLines:lines];
    } else {
        [self finishCurrentElement];
        
        LineStrip *lineStrip = [[LineStrip alloc]initLines:lines brush:brush];
        self.currentElement = lineStrip;
        [self.undoArray removeAllObjects];
        if (self.h_onElementBegin) {
            self.h_onElementBegin(self);
        }
    }
    
}
- (void)appendChartlet:(Chartlet *)chartlet {
    [self finishCurrentElement];
    id<CanvasElement> chart = (id<CanvasElement>)chartlet;
    chart.index = self.lastElementIndex + 1;
    [self.elements addObject:chart];
    [self.undoArray removeAllObjects];
    if (self.h_onElementFinish) {
        self.h_onElementFinish(self);
    }
}
- (void)appendInitialCanvasColor:(ChangeCanvasColor *)initialCanvas {
    [self.changCanvasColorActions addObject:initialCanvas];
}
- (void)appendChangeCanvasColorAction:(ChangeCanvasColor *)changeColorElement {
    [self finishCurrentElement];
    id<CanvasElement> changeColorAction = (id<CanvasElement>)changeColorElement;
    changeColorAction.index = self.lastElementIndex + 1;
    [self.elements addObject:changeColorAction];
    [self makeUndoBaseTexture];
    [self.changCanvasColorActions addObject:changeColorAction];
    [self.undoArray removeAllObjects];
    if (self.h_onElementFinish) {
        self.h_onElementFinish(self);
    }
}
- (void)appendClearAction {
    [self finishCurrentElement];
    if ([self.elements.lastObject isKindOfClass:[ClearAction class]]) {
        return;
    }
    [self.elements addObject:[ClearAction new]];
    [self makeUndoBaseTexture];
}
- (NSInteger)lastElementIndex {
    return self.elements.lastObject ? self.elements.lastObject.index : 0;
}
- (NSInteger)actionCount {
    NSUInteger count = self.elements.count;
    if (self.clearedElements.count > 0) {
        for (NSMutableArray *arr in self.clearedElements) {
            count += arr.count;
        }
        count += self.clearedElements.count;
    }
    return count;
}
- (void)finishCurrentElement {
    if (!self.currentElement) {
        return;
    }
    self.currentElement.index = self.lastElementIndex + 1;
    [self.elements addObject:self.currentElement];
    [self makeUndoBaseTexture];
    self.currentElement = nil;
    if (self.h_onElementFinish) {
        self.h_onElementFinish(self);
    }
}
- (void)makeUndoBaseTexture {
    if (self.elements.count > 0 && self.elements.count % (self.canUndoCount + 1) == 0) {
        self.snapshotTimes++;
        id<MTLTexture> snapshotTexture;
        if (self.snapshotTimes / 2 == 0) {
            snapshotTexture = self.reuseTextureArray[1];
        } else {
            snapshotTexture = self.reuseTextureArray[0];
        }
        [self.canvas.screenTarget copyTextureToTexture:snapshotTexture];
        Chartlet *undoBase = [[Chartlet alloc]initWithCenter:CGPointMake(self.canvas.bounds.size.width * 0.5, self.canvas.bounds.size.height * 0.5) size:self.canvas.bounds.size textureId:[NSUUID UUID] angle:0 canvas:self.canvas];
        undoBase.texture = snapshotTexture;

        [self.elements removeLastObject];
        [self.elements addObject:undoBase];
        
    }
    if (self.elements.count == (self.canUndoCount + 1) * 3) {
        [self.elements removeObjectsInRange:NSMakeRange(0, self.canUndoCount + 1)];
    }
}

- (UIImage *)getImageFromTexture:(id<MTLTexture>)texture {
    NSUInteger width = texture.width;
    NSUInteger height = texture.height;
    NSUInteger rowBytes = texture.width * 4;
    void *p =  malloc(width * height * 4);
    [texture getBytes:p bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    
    CGColorSpaceRef pColorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo info = kCGImageAlphaFirst | kCGBitmapByteOrder32Little;
    NSUInteger selfTureSize = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(nil, p, selfTureSize, nil);
    CGImageRef cgImageRef = CGImageCreate(width, height, 8, 32, rowBytes, pColorSpace, info, provider, nil, YES, kCGRenderingIntentDefault);
    UIImage *snapshotImage = [UIImage imageWithCGImage:cgImageRef];
    return snapshotImage;
}
//if (self.clearedElements.count > 0) {
//    NSUInteger needRemoveCount = 10;
//    NSUInteger i, j;
//    for (NSUInteger index = 0; index < self.clearedElements.count ; index++) {
//        NSArray *arr = self.clearedElements[index];
//        if (arr.count == needRemoveCount || arr.count + 1 == needRemoveCount) {
//            i = index + 1;
//            j = 0;
//            needRemoveCount = 0;
//            break;
//        } else if (arr.count > needRemoveCount) {
//            i = index;
//            j = needRemoveCount;
//            needRemoveCount = 0;
//            break;
//        } else {
//            needRemoveCount = needRemoveCount - arr.count - 1;
//        }
//    }
//    if (needRemoveCount > 0) {
//        [self.elements removeObjectsInRange:NSMakeRange(0, needRemoveCount)];
//        [self.clearedElements removeAllObjects];
//    } else {
//        [self.clearedElements removeObjectsInRange:NSMakeRange(0, i)];
//        [self.clearedElements.firstObject removeObjectsInRange:NSMakeRange(0, j)];
//    }
//} else {
//    [self.elements removeObjectsInRange:NSMakeRange(0, 10)];
//}
- (BOOL)canRedo {
    return self.undoArray.count > 0;
}
- (BOOL)canUndo {
    if (self.undoArray.count >= self.canUndoCount) {
        NSLog(@"已撤销%ld笔,不能再撤销了", self.canUndoCount);
    }
    return self.elements.count > 0 && self.undoArray.count < self.canUndoCount;
}
- (BOOL)undo {
    [self finishCurrentElement];
    if (self.canUndo) {
        id<CanvasElement> last = self.elements.lastObject;
        if (last) {
            [self.undoArray addObject:last];
            [self.elements removeLastObject];
            if ([last isKindOfClass:[ChangeCanvasColor class]]) {
                self.needDrawElements = @[];
                if (self.changCanvasColorActions.count > 1) {
                    [self.changCanvasColorActions removeLastObject];
                }
                [self.changCanvasColorActions.lastObject.canvas changeCanvasColor:self.changCanvasColorActions.lastObject.canvasColor];
                if (self.h_onUndo) {
                    self.h_onUndo(self);
                }
                return NO;
            } else {
                [self findNeedDrawElements];
            }
        } else {
            return NO;
        }
        if (self.h_onUndo) {
            self.h_onUndo(self);
        }
        return YES;
    } else {
        return NO;
    }
    
}

- (BOOL)redo {
    if (self.currentElement != nil || !self.undoArray.lastObject) {
        return  NO;
    }
    if ([self.undoArray.lastObject isKindOfClass:[ChangeCanvasColor class]]) {
        [self.elements addObject:self.undoArray.lastObject];
        [self.changCanvasColorActions addObject:self.undoArray.lastObject];
        [self.undoArray removeLastObject];
        [self.changCanvasColorActions.lastObject.canvas changeCanvasColor:self.changCanvasColorActions.lastObject.canvasColor];
        return NO;
    }
    [self.elements addObject:self.undoArray.lastObject];
    [self findNeedDrawElements];
    [self.undoArray removeLastObject];
    if (self.h_onRedo) {
        self.h_onRedo(self);
    }
    
    return YES;
}
- (void)findNeedDrawElements {
    NSMutableArray *needDrawStrokes = @[].mutableCopy;
    for (NSInteger index = self.elements.count - 1; index >= 0; index--) {
        id<CanvasElement> last = self.elements[index];
        if ([last isKindOfClass:[ClearAction class]] || [last isKindOfClass:[Chartlet class]]) {
            if ([last isKindOfClass:[Chartlet class]]) {
                self.undoBaseCharlet = (Chartlet *)last;
            } else {
                self.undoBaseCharlet = nil;
            }
            self.needDrawElements = needDrawStrokes;
            return;
        }
        if (![last isKindOfClass:[ClearAction class]] && ![last isKindOfClass:[Chartlet class]] && ![last isKindOfClass:[ChangeCanvasColor class]]) {
            [needDrawStrokes insertObject:last atIndex:0];
        }
        self.undoBaseCharlet = nil;
        self.needDrawElements = needDrawStrokes;
    }
}
- (instancetype)onElementBegin:(EventHandler)begin {
    self.h_onElementBegin = begin;
    return self;
}
- (instancetype)onElementFinish:(EventHandler)finish {
    self.h_onElementFinish = finish;
    return self;
}
- (instancetype)onRedo:(EventHandler)redo {
    self.h_onRedo = redo;
    return self;
}
- (instancetype)onUndo:(EventHandler)undo {
    self.h_onUndo = undo;
    return self;
}
@end
