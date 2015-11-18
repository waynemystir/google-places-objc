//
//  AppEnvironment.m
//  google-places-objc
//
//  Created by WAYNE SMALL on 11/16/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "AppEnvironment.h"

double const kMetersPerMile = 1609.344;

NSString * kGpoCacheDir() {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                      stringByAppendingFormat:@"/%@", [[NSBundle mainBundle] bundleIdentifier]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return path;
}