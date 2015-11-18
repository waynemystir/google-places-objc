//
//  GooglePlaceDetailsResponse.h
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 11/1/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkResponse.h"

@interface GooglePlace : NetworkResponse <NSCoding>

@property (nonatomic, strong) NSString *placeDescription;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double zoomRadius;

@end
