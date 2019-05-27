//
//  ChangeCanvasColor.h
//  Undercover
//
//  Created by Beyond on 2019/5/17.
//  Copyright © 2019 Moqipobing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CanvasData.h"
NS_ASSUME_NONNULL_BEGIN

@interface ChangeCanvasColor : NSObject<CanvasElement>
{
    NSInteger _index;
}
@property (nonatomic, weak) Canvas *canvas;
@property (nonatomic, strong) UIColor *canvasColor;

- (instancetype)initWithCanvasColor:(UIColor *)color canvas:(Canvas *)canvas;
@end

NS_ASSUME_NONNULL_END
