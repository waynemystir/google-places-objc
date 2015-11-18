//
//  GoogleAutocomplete.h
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleAutocompletePlace : NSObject

@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *placeDescription;

+ (GoogleAutocompletePlace *)placeFromDictionary:(NSDictionary *)dictionary;

@end
