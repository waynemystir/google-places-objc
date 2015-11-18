//
//  GoogleAutocomplete.m
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "GoogleAutocompleteResponse.h"
#import "GoogleAutocompletePlace.h"

@implementation GoogleAutocompleteResponse

+ (instancetype)modelFromJson:(id)json {
    if (![json isKindOfClass:[NSDictionary class]]) return nil;
    
    id predictions = [json objectForKey:@"predictions"];
    if (![predictions isKindOfClass:[NSArray class]] || ![predictions count]) return nil;
    
    NSMutableArray *mutablePredictions = [NSMutableArray arrayWithCapacity:[predictions count]];
    for (int j = 0; j < [predictions count]; j++)
        [mutablePredictions addObject:[GoogleAutocompletePlace placeFromDictionary:predictions[j]]];
    
    GoogleAutocompleteResponse *gar = [GoogleAutocompleteResponse new];
    gar.responseRecords = [mutablePredictions copy];    
    return gar;
}

@end
