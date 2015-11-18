//
//  GoogleAutocomplete.m
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "GoogleAutocompletePlace.h"

@implementation GoogleAutocompletePlace

+ (GoogleAutocompletePlace *)placeFromDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    GoogleAutocompletePlace *gap = [GoogleAutocompletePlace new];
    gap.placeId = [dictionary objectForKey:@"place_id"];
    gap.placeDescription = [dictionary objectForKey:@"description"];
    return gap;
}

@end
