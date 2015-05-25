//
//  TXShapeRecognizer.m
//  Gesture
//
//  Created by tingxin on 4/3/14.
//  Copyright (c) 2014 tingxin. All rights reserved.
//

#import "TXShapeRecognizer.h"

@interface TXShapeRecognizer()

- (void)correctStraight:(NSArray *)points errorRatio:(double)ratio compleleted:(void(^)(BOOL result,NSArray* output))callback;
- (void)correctRectangle:(NSArray *)points compleleted:(void(^)(BOOL result, NSArray* output))callback;
- (void)correctCircle:(NSArray *)points compleleted:(void(^)(BOOL result, NSArray* output))callback;
- (void)correctTriangle:(NSArray *)points compleleted:(void(^)(BOOL result, NSArray* output))callback;

@end

@implementation TXShapeRecognizer
#pragma mark --Core
+ (TXShapeRecognizer*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}


- (void)analyze:(NSArray*)points compleleted:(void(^)(TXShapeType result, NSArray* output))callback{
//    NSDate* currentTime= [NSDate date];
    __block TXShapeType typeReslt = TXShapeOther;
    __block NSArray* keyPoints = nil;
    __block BOOL success = NO;
    do {
        [[TXShapeRecognizer sharedInstance] correctStraight:points errorRatio:DefaultMinStraightRatio compleleted:^(BOOL result, NSArray *output) {
            if(result){
                success=YES;
                typeReslt=TXShapeStraight;
                keyPoints=output;
            }
        }];
        BreakIf(success);
        
        [[TXShapeRecognizer sharedInstance] correctCircle:points compleleted:^(BOOL result, NSArray *output) {
            if(result){
                success=YES;
                typeReslt=TXShapeCirle;
                keyPoints=output;
            }
        }];
        BreakIf(success);
        
        [[TXShapeRecognizer sharedInstance] correctRectangle:points compleleted:^(BOOL result, NSArray *output) {
            if(result){
                success=YES;
                typeReslt=TXShapeRectangle;
                keyPoints=output;
            }
        }];
        BreakIf(success);
        
        [[TXShapeRecognizer sharedInstance] correctTriangle:points compleleted:^(BOOL result, NSArray *output) {
            if(result){
                success=YES;
                typeReslt=TXShapeTriangle;
                keyPoints=output;
            }
        }];
        BreakIf(success);
    } while (0);
//    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:currentTime];
//    NSLog(@"TXShapeRecognizer Cost time is :%f milliseconds",interval*1000);
    callback(typeReslt,keyPoints);
}


#pragma mark --Circle
- (void)correctCircle:(NSArray *)points compleleted:(void(^)(BOOL result, NSArray* output))callback {

    do{
        BreakIf(points.count<7);
        
        __block double maxX=MINVALUE;
        __block double maxY=MINVALUE;
        __block double minX=MAXVALUE;
        __block double minY=MAXVALUE;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            if(maxX<point.x){maxX=point.x;}
            if(minX>point.x){minX=point.x;}
            if(maxY<point.y){maxY=point.y;}
            if(minY>point.y){minY=point.y;}
        }];
    
        __block CGPoint center=CGPointMake((maxX+minX)/2, (maxY+minY)/2);
        
        __block NSMutableArray *radiusArray=[NSMutableArray array];
        __block double radiusAvg=0;
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            double distance=GetDistance(center,point);
            radiusAvg+=distance;
            [radiusArray addObject:[NSNumber numberWithDouble:distance]];
        }];
        
        radiusAvg=radiusAvg/points.count;
        double radiusError=radiusAvg*RadiusErrorRatio;
        int testIndex=0;
        while(testIndex<radiusArray.count){
            NSNumber *number=[radiusArray objectAtIndex:testIndex];
            double radius=[number doubleValue];
            double distance=fabs(radiusAvg-radius);
            
            BreakIf(distance>radiusError);
            testIndex++;
        }
        BreakIf(testIndex<radiusArray.count);
        
        CGPoint radius=CGPointMake(radiusAvg, radiusAvg);
        
        NSValue *centerValue=[NSValue valueWithCGPoint:center];
        NSValue *radiusValue=[NSValue valueWithCGPoint:radius];
        
        NSArray *result=@[centerValue,radiusValue];
        
        callback(YES,result);
        return;
    } while(0);
    callback(NO,nil);
}

#pragma mark --Triangle
- (void)correctTriangle:(NSArray *)points compleleted:(void(^)(BOOL result, NSArray* output))callback {
    do {
    
        __block double maxX=MINVALUE;
        __block double maxY=MINVALUE;
        __block double minX=MAXVALUE;
        __block double minY=MAXVALUE;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            if(maxX<point.x){maxX=point.x;}
            if(minX>point.x){minX=point.x;}
            if(maxY<point.y){maxY=point.y;}
            if(minY>point.y){minY=point.y;}
        }];
        
        double diagonal=GetDistance(CGPointMake(maxX, maxY),CGPointMake(minX, minY));
        BreakIf(diagonal<MinRectangleDiagonal);
        
        NSNumber *maxXvalue=[NSNumber numberWithDouble:maxX];
        NSNumber *minXvalue=[NSNumber numberWithDouble:minX];
        NSNumber *maxYvalue=[NSNumber numberWithDouble:maxY];
        NSNumber *minYvalue=[NSNumber numberWithDouble:minY];

        NSArray *data=@[maxXvalue,minXvalue,maxYvalue,minYvalue];
        
        __block NSMutableArray *keyPoints=[NSMutableArray array];
        
        for(int i=0;i<data.count;i++){
            NSNumber *number=[data objectAtIndex:i];
            __block double check=[number doubleValue];
            
            [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
                if(point.x==check||point.y==check){
                    NSValue *key=[NSValue valueWithCGPoint:point];
                    [keyPoints addObject:key];
                    
                }
            }];
        }
        
        BreakIf(keyPoints.count<3);
        
        double maxArea=MINVALUE;
        CGPoint one;
        CGPoint two;
        CGPoint three;
        for(int i=0;i<keyPoints.count-2;i++){
            for(int j=i+1;j<keyPoints.count-1;j++){
                for(int k=j+1;k<keyPoints.count;k++){
                   CGPoint one1=[[keyPoints objectAtIndex:i] CGPointValue];
                   CGPoint two2=[[keyPoints objectAtIndex:j] CGPointValue];
                   CGPoint three3=[[keyPoints objectAtIndex:k] CGPointValue];
                    
                    double area=GetArea(one1.x, one1.y, two2.x, two2.y, three3.x, three3.y);
                    if(maxArea<area){
                        maxArea=area;
                        one=one1;
                        two=two2;
                        three=three3;
                    }
                }
            }
        }
//        NSLog(@"triangle area is about %f",maxArea);
        BreakIf(maxArea<MinShapeArea);
        
        //line 1
        double k1=(two.y-one.y)/(two.x-one.x);
        double line1Distance=GetDistance(one, two);
        
        __block double line1error=line1Distance*TriangleLineRrrorRatio;
        __block double A1=k1;__block double B1=-1;__block double C1=0-k1*one.x+one.y;
        //line 2
        double k2=(three.y-two.y)/(three.x-two.x);
        double line2Distance=GetDistance(three, two);
        __block double line2error=line2Distance*TriangleLineRrrorRatio;
        __block double A2=k2;__block double B2=-1;__block double C2=0-k2*two.x+two.y;
        //line 3
        double k3=(one.y-three.y)/(one.x-three.x);
        double line3Distance=GetDistance(one, three);
        __block double line3error=line3Distance*TriangleLineRrrorRatio;
        __block double A3=k3;__block double B3=-1;__block double C3=0-k3*three.x+three.y;
        __block int unExpectedCount=0;
        
        __block int pointsInLine1=0;
        __block int pointsInLine2=0;
        __block int pointsInLine3=0;

        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            
            BOOL isOk=NO;
            double distance1=GetDistanceFromLine(point,A1,B1,C1);
            double distance2=GetDistanceFromLine(point,A2,B2,C2);
            double distance3=GetDistanceFromLine(point,A3,B3,C3);
            
            double min=MAXVALUE;
            if(min>distance1)min=distance1;
            if(min>distance2)min=distance2;
            if(min>distance3)min=distance3;
            
            if(min==distance1&&distance1<line1error){isOk=YES;pointsInLine1++;}
            if(min==distance2&&distance2<line2error){isOk=YES;pointsInLine2++;}
            if(min==distance3&&distance3<line3error){isOk=YES;pointsInLine3++;}


            if(isOk==NO){
                unExpectedCount++;
            }
            
        }];
        BreakIf(unExpectedCount>points.count*UnExpectedCountRatio);

        BreakIf(pointsInLine1<10);
        BreakIf(pointsInLine2<10);
        BreakIf(pointsInLine3<10);
        
        NSArray *result=@[[NSValue valueWithCGPoint:one],[NSValue valueWithCGPoint:two],[NSValue valueWithCGPoint:three]];
        callback(YES,result);
        return;
    } while(0);
    callback(NO,nil);
}

#pragma mark --Rectangle
- (void)correctRectangle:(NSArray *)points compleleted:(void(^)(BOOL result, NSArray* output))callback {

    do{
        __block double maxX=MINVALUE;
        __block double maxY=MINVALUE;
        __block double minX=MAXVALUE;
        __block double minY=MAXVALUE;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            if(maxX<point.x){maxX=point.x;}
            if(minX>point.x){minX=point.x;}
            if(maxY<point.y){maxY=point.y;}
            if(minY>point.y){minY=point.y;}
        }];
        
        double diagonal=GetDistance(CGPointMake(maxX, maxY),CGPointMake(minX, minY));
        BreakIf(diagonal<MinRectangleDiagonal);
        
        __block double adjustWidth=(maxX-minX)/16;
        __block double adjustHeight=(maxY-minY)/16;
        __block int unExpectedCount=0;
        NSMutableArray *topPoints=[NSMutableArray array];
        NSMutableArray *bottomPoints=[NSMutableArray array];
        NSMutableArray *leftPoints=[NSMutableArray array];
        NSMutableArray *rightPoints=[NSMutableArray array];
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {

            BOOL isIn=NO;
            if(fabs(point.x-maxX)<adjustWidth){
                [rightPoints addObject:[NSValue valueWithCGPoint:point]];
                isIn=YES;
            }
            if(fabs(point.x-minX)<adjustWidth){
                [leftPoints addObject:[NSValue valueWithCGPoint:point]];
                isIn=YES;
            }
            if(fabs(point.y-maxY)<adjustHeight){
                [bottomPoints addObject:[NSValue valueWithCGPoint:point]];
                isIn=YES;
            }
            if(fabs(point.y-minY)<adjustHeight)
            {
                [topPoints addObject:[NSValue valueWithCGPoint:point]];
                isIn=YES;
            }
            if(isIn==NO){
                unExpectedCount++;
            }
        }];
        
        BreakIf(unExpectedCount>points.count*UnExpectedCountRatio);

        double topLineLength=GetLineLength(topPoints);
        double bottomLineLength=GetLineLength(bottomPoints);
        double leftLineLength=GetLineLength(leftPoints);
        double rightLineLength=GetLineLength(rightPoints);
        
        double perimeter=topLineLength+bottomLineLength+leftLineLength+rightLineLength;
        
        double topPointsRatio=topLineLength/perimeter;
        double bottomPointsRatio=bottomLineLength/perimeter;
        double leftPointsRatio=leftLineLength/perimeter;
        double rightPointsRatio=rightLineLength/perimeter;
        
        int minTopPointsCount=topPointsRatio*points.count-10;
        BreakIf(minTopPointsCount>topPoints.count);
        
        int minBottomPointsCount=bottomPointsRatio*points.count-10;
        BreakIf(minBottomPointsCount>bottomPoints.count);

        int minLeftPointsCount=leftPointsRatio*points.count-10;
        BreakIf(minLeftPointsCount>leftPoints.count);

        int minRightPointsCount=rightPointsRatio*points.count-10;
        BreakIf(minRightPointsCount>rightPoints.count);

        __block double topAverage=0;
        __block double bottomAverage=0;
        __block double leftAverage=0;
        __block double rightAverage=0;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:topPoints itemCall:^(CGPoint point) {
            topAverage+=point.y;
        }];
        topAverage=topAverage/topPoints.count;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:bottomPoints itemCall:^(CGPoint point) {
            bottomAverage+=point.y;
        }];
        bottomAverage=bottomAverage/bottomPoints.count;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:leftPoints itemCall:^(CGPoint point) {
            leftAverage+=point.x;
        }];
        leftAverage=leftAverage/leftPoints.count;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:rightPoints itemCall:^(CGPoint point) {
            rightAverage+=point.x;
        }];
        rightAverage=rightAverage/rightPoints.count;
        
        CGPoint leftTop=CGPointMake(leftAverage, topAverage);
        CGPoint rightTop=CGPointMake(rightAverage, topAverage);
        CGPoint rightBottom=CGPointMake(rightAverage, bottomAverage);
        CGPoint leftBottom=CGPointMake(leftAverage, bottomAverage);
        
        NSValue *leftTopValue=[NSValue valueWithCGPoint:leftTop];
        NSValue *rightTopValue=[NSValue valueWithCGPoint:rightTop];
        NSValue *rightBottomValue=[NSValue valueWithCGPoint:rightBottom];
        NSValue *leftBottomValue=[NSValue valueWithCGPoint:leftBottom];

        NSArray *result=@[leftTopValue,rightTopValue,rightBottomValue,leftBottomValue];
        callback(YES,result);
        return;
    } while(0);
    callback(NO,nil);
}

#pragma mark --Straight
- (void)correctStraight:(NSArray *)points errorRatio:(double)ratio compleleted:(void(^)(BOOL result, NSArray* output))callback {
    do{
        BreakIf(points.count<2);
        
        __block double maxX=MINVALUE;
        __block double maxY=MINVALUE;
        __block double minX=MAXVALUE;
        __block double minY=MAXVALUE;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            if(maxX<point.x){maxX=point.x;}
            if(minX>point.x){minX=point.x;}
            if(maxY<point.y){maxY=point.y;}
            if(minY>point.y){minY=point.y;}
        }];
        
        double lineLength=GetDistance(CGPointMake(maxX, maxY),CGPointMake(minX, minY));
        double offset=ratio*lineLength/50;

        
        __block double xAverage=0;
        __block double yAverage=0;
        __block double startX=MAXVALUE;
        __block double endX=MINVALUE;

        __block double fenzi=0.0;
        __block double fenmu=0.0;
        
        [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
            xAverage+=point.x;
            yAverage+=point.y;
            
            if(endX<point.x){
                endX=point.x;
            }
            
            if(startX>point.x){
                startX=point.x;
            }
            
            fenzi+=point.x*point.y;
            fenmu+=point.x*point.x;
        }];

        xAverage=xAverage/points.count;
        yAverage=yAverage/points.count;
        
        fenzi=fenzi-points.count*xAverage*yAverage;
        fenmu=fenmu-points.count*xAverage*xAverage;
        
        __block double a=0.0;
        __block double b=0.0;
        
        if(fenmu!=0){
            b=fenzi/fenmu;
        }
        
        if(fenmu==0||fenzi==0||fabs(b)>6){
            __block double startYTest=MAXVALUE;
            __block double endYTest=MINVALUE;
            __block int unExpectedCount=0;
            
            [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
                if(endYTest<point.y){
                    endYTest=point.y;
                }
                
                if(startYTest>point.y){
                    startYTest=point.y;
                }
                
                if(fabs(xAverage-point.x)>offset*2){
                    unExpectedCount++;
                }
            }];
            
            BreakIf(unExpectedCount>points.count*UnExpectedCountRatio);
            
            NSMutableArray *correctPoints=[self getCorrectLinePointsWithStartX:xAverage startY:startYTest endX:xAverage endY:endYTest];
            callback(YES,correctPoints);
            return;
        }
        else{
            a=yAverage-b*xAverage;
            __block int unExpectedCount=0;

            [[TXShapeRecognizer sharedInstance] ForEachCGPoints:points itemCall:^(CGPoint point) {
                double offsetY=a+b*point.x;
                if(fabs(offsetY-point.y)>offset){
                    unExpectedCount++;
                }
            }];

           BreakIf(unExpectedCount>points.count*UnExpectedCountRatio);
            
            double startY=a+b*startX;
            double endY=a+b*endX;
            NSMutableArray *correctPoints=[self getCorrectLinePointsWithStartX:startX startY:startY endX:endX endY:endY];
            callback(YES,correctPoints);
            return;
        }
        
    } while(0);
    
    callback(NO,nil);
}

#pragma mark --helper

- (NSMutableArray *)getCorrectLinePointsWithStartX:(double)sX startY:(double)sy endX:(double)ex endY:(double)ey {
    NSMutableArray *correctPoints=[[NSMutableArray alloc] init];
    CGPoint startCorrectPoint=CGPointMake(sX, sy);
    NSValue *startValue=[NSValue valueWithCGPoint:startCorrectPoint];
    
    CGPoint endCorrectPoint=CGPointMake(ex, ey);
    NSValue *endValue=[NSValue valueWithCGPoint:endCorrectPoint];
    
    [correctPoints addObject:startValue];
    [correctPoints addObject:endValue];
    
    return correctPoints;
}

- (void)ForEachCGPoints:(NSArray *)points itemCall:(void(^)(CGPoint point))callback {

    for (int i=0;i<points.count; i++) {
        NSValue *currentOBj=[points objectAtIndex:i];
        CGPoint point=[currentOBj CGPointValue];
        callback(point);
    }
}

double GetLineLength(NSArray * line){
    
    double dis=MINVALUE;
    for(int i=0;i<line.count-1;i++){
        for(int j=i+1;j<line.count;j++){
            NSValue *one=line[i];
            NSValue *two=line[j];
            CGPoint startPoint=[one CGPointValue];
            CGPoint endPoint=[two CGPointValue];
            double distance=GetDistance(startPoint, endPoint);
            if(dis<distance){
                dis=distance;
            }
        }
    }
    return dis;
}


@end
