//
//  VoronoiMath.h
//  DrawBoard
//
//  Created by Mikko on 01/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef DrawBoard_VoronoiMath_h
#define DrawBoard_VoronoiMath_h
#include "VoronoiDefs.h"
#include <stdbool.h>
#include <CoreGraphics/CoreGraphics.h>

bool circleFormula(VPoint p1, VPoint p2, VPoint p3,
                   VPoint *center, VDouble *radius);

VDouble parabolaAtX(VDouble x, VPoint site, VDouble scanline);

typedef struct QuadraticRoots_ {
    bool has_root1;
    VDouble root1;
    bool has_root2;
    VDouble root2;
} QuadraticRoots_t;


// Returns the X coordinate of a breakpoint:
VDouble parabolaBreakpoint(VPoint left, VPoint right, 
                           VDouble scanline, 
                           QuadraticRoots_t roots,
                           VDouble domainLeft);

VDouble parabolaAtX(VDouble x, VPoint site, VDouble scanline);

QuadraticRoots_t parabolaIntersection(VPoint p, VPoint q, VDouble scanline);


bool circleFormula(VPoint p1, VPoint p2, VPoint p3,
                   VPoint *center, VDouble *radius);


CGPoint lineIntersect(CGPoint point_a1, CGPoint point_a2,
                      CGPoint point_b1, CGPoint point_b2);

#endif
