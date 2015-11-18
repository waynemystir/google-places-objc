//
//  AppEnvironment.h
//  google-places-objc
//
//  Created by WAYNE SMALL on 11/16/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

extern double const kMetersPerMile;
extern NSString * kGpoCacheDir();
