//
//  ViewController.m
//  DrawGuessDemo
//
//  Created by Beyond on 2019/5/27.
//  Copyright © 2019 Freelf. All rights reserved.
//

#import "ViewController.h"
#import "WBMetalCanvasView.h"
@interface ViewController ()
@property (nonatomic, strong) WBMetalCanvasView *metalCanvasView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.metalCanvasView = [[WBMetalCanvasView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width)];
    self.metalCanvasView.backgroundColor = [UIColor colorWithRed:0.97 green:0.98 blue:0.88 alpha:1.00];
    [self.view addSubview:self.metalCanvasView];
    
}
- (void)startDraw {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *pathArray = [self loadJsonDataWithPath:@"ddd"];
        NSDictionary *dict = @{
                               @"strokeType" : @(-1),
                               @"drawStrokes" : pathArray
                               };
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.metalCanvasView onReceiveDrawCommandInfo:dict];
        });
    });
}
-(NSArray *)loadJsonDataWithPath: (NSString *)path {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:path ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return result;
}

@end
