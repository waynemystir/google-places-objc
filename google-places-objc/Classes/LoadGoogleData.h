//
//  LoadGoogleData.h
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkResponse.h"

typedef NS_ENUM(NSUInteger, GOOGLE_DATA_TYPE) {
    GOOGLE_AUTOCOMPLETE,
    GOOGLE_PLACE_DETAILS
};

@protocol LoadGoogleDataDelegate <NSObject>

@required

- (void)loadedData:(GOOGLE_DATA_TYPE)dataType toObject:(NetworkResponse *)googleObject;
- (void)requestTimedOut:(GOOGLE_DATA_TYPE)dataType;
- (void)requestFailedOffline:(GOOGLE_DATA_TYPE)dataType;
- (void)requestFailed:(GOOGLE_DATA_TYPE)dataType;

@end

@interface LoadGoogleData : NSObject

@property (nonatomic, weak) id<LoadGoogleDataDelegate> googleDelegate;

+ (LoadGoogleData *)manager;
+ (NSURLSessionTask *)autocomplete:(NSString *)autocompleteText;
+ (NSURLSessionTask *)loadPlaceDetails:(NSString *)placeId;

@end
