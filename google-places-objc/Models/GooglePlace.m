//
//  GooglePlaceDetailsResponse.m
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 11/1/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "GooglePlace.h"
#import <MapKit/MapKit.h>
#import "AppEnvironment.h"

NSString * const kKeyFormattedAddress = @"formattedAddress";
NSString * const kKeyPlacePlaceId = @"placeId";
NSString * const kKeyPlaceLatitude = @"latitude";
NSString * const kKeyPlaceLongitude = @"longitude";
NSString * const kKeyZoomRadius = @"zoomRadius";

@implementation GooglePlace

+ (instancetype)modelFromJson:(id)json {
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    id result = [json objectForKey:@"result"];
    if (![result isKindOfClass:[NSDictionary class]]) return nil;
    
    GooglePlace *gpdr = [GooglePlace new];
    gpdr.placeId = [result objectForKey:@"place_id"];
    gpdr.placeDescription = [result objectForKey:@"formatted_address"];
    id geometry = [result objectForKey:@"geometry"];
    id location = [geometry objectForKey:@"location"];
    gpdr.latitude = [[location objectForKey:@"lat"] floatValue];
    gpdr.longitude = [[location objectForKey:@"lng"] floatValue];
    id viewport = [geometry objectForKey:@"viewport"];
    gpdr.zoomRadius = [self viewportToMilesRadius:viewport];
    
    return gpdr;
}

+ (double)viewportToMilesRadius:(id)viewport {
    static double defaultZoomRadius = 3.0;
    if (![viewport isKindOfClass:[NSDictionary class]]) return defaultZoomRadius;
    
    NSDictionary *northeast = [viewport objectForKey:@"northeast"];
    if (!northeast) return defaultZoomRadius;
    
    NSDictionary *southwest = [viewport objectForKey:@"southwest"];
    if (!southwest) return defaultZoomRadius;
    
    double neLat = [[northeast objectForKey:@"lat"] doubleValue];
    double neLng = [[northeast objectForKey:@"lng"] doubleValue];
    double swLat = [[southwest objectForKey:@"lat"] doubleValue];
    double swLng = [[southwest objectForKey:@"lng"] doubleValue];
    
    CLLocation *neLoc = [[CLLocation alloc] initWithLatitude:neLat longitude:neLng];
    CLLocation *swLoc = [[CLLocation alloc] initWithLatitude:swLat longitude:swLng];
    
    CLLocationDistance distance = [swLoc distanceFromLocation:neLoc];
    return distance / kMetersPerMile;
}

#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _placeDescription = [aDecoder decodeObjectForKey:kKeyFormattedAddress];
        _placeId = [aDecoder decodeObjectForKey:kKeyPlacePlaceId];
        _latitude = [aDecoder decodeDoubleForKey:kKeyPlaceLatitude];
        _longitude = [aDecoder decodeDoubleForKey:kKeyPlaceLongitude];
        _zoomRadius = [aDecoder decodeDoubleForKey:kKeyZoomRadius];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_placeDescription forKey:kKeyFormattedAddress];
    [aCoder encodeObject:_placeId forKey:kKeyPlacePlaceId];
    [aCoder encodeDouble:_latitude forKey:kKeyPlaceLatitude];
    [aCoder encodeDouble:_longitude forKey:kKeyPlaceLongitude];
    [aCoder encodeDouble:_zoomRadius forKey:kKeyZoomRadius];
}

@end
