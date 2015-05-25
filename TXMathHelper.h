//
//  SRMathHelper.h
//  SpringRollManager
//
//  Created by tingxin on 7/22/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIGeometry.h>

@interface TXMathHelper : NSObject
double GetDistance(CGPoint startPoint,CGPoint endPoint);
double GetDistanceFromLine(CGPoint point,double A,double B,double C);

double GetArea(double x1,double y1,double x2,double y2,double x3,double y3);
@end
