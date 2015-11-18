//
//  Places.h
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 11/1/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlace.h"

@interface Places : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray *savedPlaces;
@property (nonatomic, strong) GooglePlace *selectedPlace;
@property (nonatomic, readonly) BOOL currentLocationIsSelectedPlace;

+ (Places *)manager;

@end
