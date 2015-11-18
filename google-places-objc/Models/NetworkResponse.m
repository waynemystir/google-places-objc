//
//  NetworkModel.m
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "NetworkResponse.h"

@implementation NetworkResponse

+ (instancetype)modelFromData:(NSData *)data {
    if (!data) return nil;
    
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        NSLog(@"%s ERROR trying to deserialize JSON data:%@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    if (![NSJSONSerialization isValidJSONObject:json]) {
        NSLog(@"%s ERROR: Response is not valid JSON", __PRETTY_FUNCTION__);
        return nil;
    }
    
    return [self modelFromJson:json];
}

+ (instancetype)modelFromJson:(id)json {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
