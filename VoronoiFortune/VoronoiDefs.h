//
//  VoronoiDefs.h
//  VoronoiFortune
//
//  Created by Mikko on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef VoronoiFortune_VoronoiDefs_h
#define VoronoiFortune_VoronoiDefs_h
#include <CoreGraphics/CoreGraphics.h>
#include <limits.h>
#include <float.h>

typedef long double VDouble;
#define VDOUBLE_MAX LDBL_MAX
#define VDOUBLE_MIN LDBL_MIN


typedef struct {
    VDouble x;
    VDouble y;
} VPoint;


static inline
VPoint VPointMake(VDouble x, VDouble y)
{
    VPoint vp;
    vp.x = x;
    vp.y = y;
    return vp;
}


static inline
VPoint VPointFromCGPoint(CGPoint cgp)
{
    VPoint vp;
    vp.x = (CGFloat)cgp.x;
    vp.y = (CGFloat)cgp.y;
    return vp;
}


static inline
CGPoint CGPointFromVPoint(VPoint vp)
{
    CGPoint cgp;
    cgp.x = (CGFloat)vp.x;
    cgp.y = (CGFloat)vp.y;
    return cgp;
}

#endif
