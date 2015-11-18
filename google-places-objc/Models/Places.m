//
//  Places.m
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 11/1/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "Places.h"
#import "AppEnvironment.h"

NSInteger const kMaxNumbOfSavedPlaces = 20;
NSString * const kGooglePlaceCurrentLocationId = @"kGooglePlaceCurrentLocationId";
NSString * const kKeyPlacesArray = @"kKeyPlacesArray";
NSString * const kKeySelectedPlace = @"kKeySelectedPlace";

@interface Places ()

@property (nonatomic, strong) NSMutableArray *savedPlacesMutable;

@end

@implementation Places

+ (void)load {
    [self manager].selectedPlace = [self manager].savedPlaces.firstObject;
}

+ (Places *)manager {
    static Places *_places = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* path = [self pathForPlaces];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            _places = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_places) {
            _places = [[self alloc] init];
            GooglePlace *wp = [[GooglePlace alloc] init];
            wp.placeId = kGooglePlaceCurrentLocationId;
            wp.placeDescription = @"Current Location";
            wp.zoomRadius = 20.0;
            _places.savedPlacesMutable = [@[wp] mutableCopy];
            _places.selectedPlace = wp;
            [_places save];
        }
    });
    
    return _places;
}

#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _savedPlacesMutable = [aDecoder decodeObjectForKey:kKeyPlacesArray];
        _selectedPlace = [aDecoder decodeObjectForKey:kKeySelectedPlace];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_savedPlacesMutable forKey:kKeyPlacesArray];
    [aCoder encodeObject:_selectedPlace forKey:kKeySelectedPlace];
}

#pragma mark Storing methods

- (void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[[self class] pathForPlaces]];
}

+ (NSString *)pathForPlaces {
    return [kGpoCacheDir() stringByAppendingString:@"/places"];
}

#pragma mark Getters

- (NSArray *)savedPlaces {
    return [self.savedPlacesMutable copy];
}

- (BOOL)currentLocationIsSelectedPlace {
    return [_selectedPlace.placeId isEqualToString:kGooglePlaceCurrentLocationId];
}

#pragma mark Setters

- (void)setSelectedPlace:(GooglePlace *)selectedPlace {
    if (!selectedPlace) return;
    _selectedPlace = selectedPlace;    
    if (self.currentLocationIsSelectedPlace) return;
    
    for (int j = 0; j < self.savedPlacesMutable.count; j++) {
        GooglePlace *wp = [_savedPlacesMutable objectAtIndex:j];
        if([wp.placeDescription isEqualToString:_selectedPlace.placeDescription]
                || [wp.placeId isEqualToString:_selectedPlace.placeId]) {
            
            [self.savedPlacesMutable removeObjectAtIndex:j];
            
        }
    }
    
    [self.savedPlacesMutable insertObject:_selectedPlace atIndex:1];
    while ((NSInteger)self.savedPlacesMutable.count - kMaxNumbOfSavedPlaces > 0)
        [self.savedPlacesMutable removeObjectAtIndex:(self.savedPlacesMutable.count - 1)];
    [self save];
}

@end
