//
//  SRMathHelper.m
//  SpringRollManager
//
//  Created by tingxin on 7/22/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import "TXMathHelper.h"

@implementation TXMathHelper

double GetDistance(CGPoint startPoint,CGPoint endPoint){
    double result=(endPoint.x-startPoint.x)*(endPoint.x-startPoint.x)+(endPoint.y-startPoint.y)*(endPoint.y-startPoint.y);
    return sqrt(result);
}

double GetDistanceFromLine(CGPoint point,double A,double B,double C)
{
    double fenzi=fabs(A*point.x+B*point.y+C);
    double fenmu=sqrt(A*A+B*B);
    
    return fenzi/fenmu;
}

double GetArea(double x1,double y1,double x2,double y2,double x3,double y3 ){
    double pa=0.5*fabs(x1*y2+x2*y3+x3*y1-y1*x2-y2*x3-y3*x1);
    return pa;
}
@end
