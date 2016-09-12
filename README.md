# Shape Recognition for ios
Analyse if a points array can be a shape and correct it to a regular shape  

# How to use:

    [[TXShapeRecognizer sharedInstance] Analyze: points compleleted:^(TXShapeType result, NSArray *output) {
        switch (result) {
            case TXShapeStraight:
                NSLog(@"Stright");
                break;
            case TXShapeRectangle:
                NSLog(@"Rectangle");
                break;
            case TXShapeCirle:
                NSLog(@"Circle");
                break;
            case TXShapeTriangle:
                NSLog(@"Triangle");
                break;
            default:
                NSLog(@"Others");
                break;
        }
    }];

the parameter "points" is an array of CGPoint, in the return call back, the result will be fllow option：
    TXShapeOther        
    TXShapeStraight     
    TXShapeCirle        
    TXShapeRectangle    
    TXShapeTriangle
    
if the result is TXShapeOther, the output will be nil, if not, the output will also be an array of GCPoint, you can use this array to build a regular shape
