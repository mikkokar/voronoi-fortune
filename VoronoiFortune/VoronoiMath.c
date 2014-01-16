//
//  VoronoiCommon.c
//  DrawBoard
//
//  Created by Mikko on 01/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// #include <ApplicationServices/ApplicationServices.h>

#include <stdio.h>
#include "VoronoiMath.h"
#include <math.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

static
void swapPoints(VPoint *pa, VPoint *pb)
{
    VPoint tmp;
    tmp = *pa;
    *pa = *pb;
    *pb = tmp;
}


static bool computeCircle(VPoint p1, VPoint p2, VPoint p3,
                          VPoint *center, VDouble *radius)
{
    VDouble cx, cy;
    
    VDouble ka = (p2.y - p1.y)/(p2.x - p1.x);
    VDouble kb = (p3.y - p2.y)/(p3.x - p2.x);
        
    if (kb - ka == 0) {
        // Trouble
        return false;
    }
    if (ka == 0) {
        // Trouble;
        return false;
    }
    
    cx = (ka*kb*(p1.y - p3.y) + kb*(p1.x + p2.x) - ka*(p2.x + p3.x))/
    (2.0*(kb - ka));
    cy = (-1.0/ka)*(cx - (p1.x + p2.x)/2.0) + (p1.y + p2.y)/2.0;
    
    if (!center) {
        return false;
    }
    center->x = cx;
    center->y = cy;
    
    if (!radius) {
        return false;
    }
    
    *radius = sqrt((cx - p1.x)*(cx - p1.x) + (cy - p1.y)*(cy - p1.y));
 
    return true;
}

static bool computeSpecialCaseCircle(VPoint p1, VPoint p2, VPoint p3,
                                     VPoint *center, VDouble *radius)
{
    if (!center || !radius) {
        return false;
    }
    if (p1.x != p2.x) {
        center->x = (p1.x + p2.x)/2.0;
        center->y = (p2.y + p3.y)/2.0;
    } else {
        center->x = (p2.x + p3.x)/2.0;
        center->y = (p1.x + p2.x)/2.0;
    }
    *radius = sqrt((center->x - p1.x)*(center->x - p1.x) + 
                   (center->y - p1.y)*(center->y - p1.y));
    return true;
}



static bool sloped_line(VPoint p1, VPoint p2)
{
    if (p1.y == p2.y) {
        // Horizontal line, no sloping
        return false;
    }
    if (p1.x == p2.x) {
        // Vertical line, no sloping
        return false;
    }
    return true;
}


bool circleFormula(VPoint p1, VPoint p2, VPoint p3,
                   VPoint *center, VDouble *radius)
{
    /*
        Points-array is used to find a two consecutive sloping lines, 
        that can be pased to computeCircle() function, guaranteeing
        non-zero denominatiors for circle equations.

        Points-array is used to scan through following combinations
        of potential line-segments:
     
        i=0 line(p1, p2)
        i=1 line(p2, p3)
        i=2 line(p3, p1) 
        i=3 line(p1, p2)
     
     */
    VPoint points[] = { p1, p2, p3, p1, p2 };
    int lineInd = -1;

    /*
     
     Need at least four line segments in points-array in order to
     correctly detect lines i=2 and i=3 for computeCircle:
     
     i=0 line(p1, p2)  sloping
     i=1 line(p2, p3)  non-sloping
     i=2 line(p3, p1)  sloping
     i=3 line(p1, p2)  sloping
     
    */
     
    for (lineInd = 0; lineInd < 3; lineInd++) {
        bool slope1 = sloped_line(points[lineInd + 0], points[lineInd + 1]);
        bool slope2 = sloped_line(points[lineInd + 1], points[lineInd + 2]);
        if (slope1 && slope2) {
            // Found two sloped lines.
            return computeCircle(points[lineInd], 
                                 points[lineInd+1], 
                                 points[lineInd+2], 
                                 center, radius);
        }
    }
    
    // Not found. Find two consecutive non-slopes:
    /*
     
     Similarly, for a potential special case handler, we need at 
     least four line segments in points-array in order to
     correctly detect lines i=2 and i=3 for computeCircle:
     
     i=0 line(p1, p2)  non-sloping
     i=1 line(p2, p3)  sloping
     i=2 line(p3, p1)  non-sloping
     i=3 line(p1, p2)  non-sloping
     
     Well, special case handler could cope with 3 or 4 point array 
     only. But this doesn't really matter as the original array does
     equally well:
     
     */
    for (lineInd = 0; lineInd < 3; lineInd++) {
        bool slope1 = sloped_line(points[lineInd + 0], points[lineInd + 1]);
        bool slope2 = sloped_line(points[lineInd + 1], points[lineInd + 2]);
        
        if (slope1 == false && slope2 == false) {
            return computeSpecialCaseCircle(points[lineInd],
                                            points[lineInd+1],
                                            points[lineInd+2],
                                            center, radius);
        }
    }
    
    return false;
}



QuadraticRoots_t parabolaIntersection(VPoint p, VPoint q, VDouble scanline)
{
    QuadraticRoots_t roots;
    VDouble s = scanline;// -1.0*scanline;
    
    roots.has_root1 = false;
    roots.has_root2 = false;
    
    if (p.y - s == 0) {
        roots.has_root1 = true;
        roots.root1 = p.x;
        return roots;
    }
    if (q.y - s == 0) {
        roots.has_root1 = true;
        roots.root1 = q.x;
        return roots;
    }
    
    VDouble Cp = ((-1.0*(p.y - s)*(p.y - s))/(2.0*(p.y - s))) + p.y;
    VDouble Cq = ((-1.0*(q.y - s)*(q.y - s))/(2.0*(q.y - s))) + q.y;
    
    VDouble R = p.y - s;
    VDouble S = q.y - s;
    
    VDouble A = S - R;
    VDouble B = 2.0*R*q.x - 2.0*S*p.x;
    VDouble C = S*p.x*p.x - R*q.x*q.x - 2.0*R*S*(Cq - Cp);
    
    //NSLog(@"Intersection, p=(%f, %f), q=(%f, %f), Cp=%f, Cq=%f, R=%f, S=%f, A=%f, B=%f, C=%f", 
    //      p.x, p.y, q.x, q.y, Cp, Cq, R, S, A, B, C);
    
    if (q.y - p.y != 0) {
        //NSLog(@"Intersection, case 1");
        
        VDouble D = B*B - 4*A*C;
        if (D < 0) {
            roots.has_root1 = false;
            roots.has_root2 = false;
            return roots;
        }
        VDouble x1 = (-1.0*B + sqrt(D))/(2.0*A);
        VDouble x2 = (-1.0*B - sqrt(D))/(2.0*A);
        roots.has_root1 = true;
        roots.root1 = x1;
        if (abs(x1 - x2) < 0.000000001) {
            roots.has_root2 = false;
        } else {
            roots.has_root2 = true;
            roots.root2 = x2;
        }
    } else if (B != 0) {
        //NSLog(@"Intersection, case 2");
        VDouble x = -1.0*C/B;
        roots.has_root1 = true;
        roots.root1 = x;
        roots.has_root2 = false;
    } else {
        //NSLog(@"Intersection, case 3");
        roots.has_root1 = false;
        roots.has_root2 = false;
    }
    return roots;
}



VDouble parabolaAtX(VDouble x, VPoint site, VDouble scanline)
{
    site.x = site.x;
    site.y = -1*site.y;
    scanline = -1*scanline;
    
    VDouble foo;
    foo = ((x - site.x)*(x - site.x) - (site.y - scanline)*(site.y - scanline))/
    (2*(site.y - scanline)) + site.y;
    return -1*foo;
}


// Returns the X coordinate of a breakpoint:
VDouble parabolaBreakpoint(VPoint left, VPoint right, 
                           VDouble scanline, 
                           QuadraticRoots_t roots,
                           VDouble domainLeft)
{
    VDouble retval;
    // if only one root:
    if (roots.has_root1 && !roots.has_root2) {
        retval = roots.root1;
    } else if (roots.has_root1 && roots.has_root2) {
        /* Make sure the roots are in ascending order */
        if (roots.root1 > roots.root2) {
            VDouble tmp = roots.root1;
            bool has_tmp = roots.has_root1;
            roots.root1 = roots.root2;
            roots.has_root1 = roots.has_root2;
            roots.root2 = tmp;
            roots.has_root2 = has_tmp;
        }
        
        if (ceil(roots.root1) > ceil(domainLeft)) {
            retval = roots.root1;
        } else {
            // assert(roots.root2 >= domainLeft);
            retval = roots.root2;
        }
    } else {
        assert(0 && "Error no roots found for parabola breakpoint");
    }
    return retval;
}


static CGFloat
crossProduct(CGPoint a, CGPoint b)
{
    return (a.x*b.y - a.y*b.x);
}

CGPoint lineIntersect(CGPoint point_a1, CGPoint point_a2,
                      CGPoint point_b1, CGPoint point_b2)
{
    CGPoint r1, r2;
    CGPoint s1, s2;
    
    r1 = point_a1;
    r2 = CGPointMake(point_a2.x - point_a1.x,
                     point_a2.y - point_a1.y);
    
    s1 = point_b1;
    s2 = CGPointMake(point_b2.x - point_b1.x, 
                     point_b2.y - point_b1.y);
    
    CGPoint q = s1;
    CGPoint p = r1;
    CGPoint r = r2; //CGPointMake(r2.x - r1.x, r2.y - r1.y);
    CGPoint s = s2; //CGPointMake(s2.x - s1.x, s2.y - s1.y);
    
    CGPoint qminusp = CGPointMake(q.x - p.x, q.y - p.y);
    CGFloat cross_rs = crossProduct(r, s);
    
    if (cross_rs) {
        CGFloat t = crossProduct(qminusp, s)/crossProduct(r, s);
        CGFloat u = crossProduct(qminusp, r)/crossProduct(r, s);
        if ((t > 0.0 && t < 1.0) && (u > 0.0 && u < 1.0)) {
            CGPoint intersect = CGPointMake(p.x + t*r.x,
                                            p.y + t*r.y);
            return intersect;
        }
    }
    return CGPointZero;
}
