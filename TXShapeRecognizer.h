//
//  TXShapeRecognizer.h
//  Created by tingxin on 4/3/14.
//  Copyright (c) 2014 tingxin. All rights reserved.
//====================================================== how to use =================================================
//[[TXShapeRecognizer sharedInstance] Analyze: points compleleted:^(TXShapeType result, NSArray *output) {
//    switch (result) {
//        case TXShapeStraight:
//            NSLog(@"Stright");
//            break;
//        case TXShapeRectangle:
//            NSLog(@"Rectangle");
//            break;
//        case TXShapeCirle:
//            NSLog(@"Circle");
//            break;
//        case TXShapeTriangle:
//            NSLog(@"Triangle");
//            break;
//        default:
//            NSLog(@"Others");
//            break;
//    }
//}];
//===================================================================================================================

#import "TXMathHelper.h"

#define BreakIf(condition)          if(condition)break
#define DefaultMinStraightRatio     1.8
#define MinLineLength               10
#define MinRectangleDiagonal        100
#define TriangleLineRrrorRatio      0.1
#define MinShapeArea                2000
#define RadiusErrorRatio            0.18
#define UnExpectedCountRatio        0.12
#define MINVALUE                    -10000000
#define MAXVALUE                    10000000

typedef enum {
    TXShapeOther        = 0,
    TXShapeStraight     = 1,
    TXShapeCirle        = 2,
    TXShapeRectangle    = 3,
    TXShapeTriangle     = 4
} TXShapeType;


@interface TXShapeRecognizer : NSObject
{
    NSMutableArray *tasks;
}

+ (TXShapeRecognizer *)sharedInstance;
- (void)analyze:(NSArray *)points compleleted:(void(^)(TXShapeType result, NSArray* output))callback;

@end
