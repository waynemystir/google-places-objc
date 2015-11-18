//
//  NetworkModel.h
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkResponse : NSObject

@property (nonatomic, strong) id responseRecords;

+ (instancetype)modelFromData:(NSData *)data;
+ (instancetype)modelFromJson:(id)json;

@end
