//
//  UIColor+Extension.h
//  DrawGuessDemo
//
//  Created by Beyond on 2019/5/27.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Extension)
- (instancetype)initWithHex:(NSString *)hex;
+ (instancetype)wb_colorWithHex:(NSString *)hex;
@end

NS_ASSUME_NONNULL_END
