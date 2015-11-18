//
//  LoadGoogleData.m
//  GooglePlacesAndMapsObjC
//
//  Created by WAYNE SMALL on 10/31/15.
//  Copyright © 2015 Waynemystir. All rights reserved.
//

#import "LoadGoogleData.h"
#import "GoogleAutocompleteResponse.h"
#import "GooglePlace.h"

NSString * const GOOGLE_API_KEY = @"Your API Key";
NSString * const AUTOCOMPLETE_BASE_URL = @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
NSString * const PLACE_DETAILS_BASE_URL = @"https://maps.googleapis.com/maps/api/place/details/json";

@implementation LoadGoogleData

+ (LoadGoogleData *)manager {
    static LoadGoogleData *_lgd = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lgd = [LoadGoogleData new];
    });
    
    return _lgd;
}

+ (NSURLSessionTask *)autocomplete:(NSString *)autocompleteText {
    NSString *urlStr = [NSString stringWithFormat:@"%@?input=%@&key=%@", AUTOCOMPLETE_BASE_URL, autocompleteText, GOOGLE_API_KEY];
    return [self dataTaskWithUrl:urlStr type:GOOGLE_AUTOCOMPLETE class:[GoogleAutocompleteResponse class]];
}

+ (NSURLSessionTask *)loadPlaceDetails:(NSString *)placeId {
    NSString *urlStr = [NSString stringWithFormat:@"%@?placeid=%@&key=%@", PLACE_DETAILS_BASE_URL, placeId, GOOGLE_API_KEY];
    return [self dataTaskWithUrl:urlStr type:GOOGLE_PLACE_DETAILS class:[GooglePlace class]];
}

+ (NSURLSessionTask *)dataTaskWithUrl:(NSString *)url type:(GOOGLE_DATA_TYPE)dataType class:(Class)class {
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([self handleError:error dataType:dataType] || [self handleResponse:response dataType:dataType]) return;
        if (!data) return [self performDelegateSelector:@selector(requestFailed:) dataType:dataType parameter2:nil];
        NetworkResponse *nr = [class modelFromData:data];
        [self performDelegateSelector:@selector(loadedData:toObject:) dataType:dataType parameter2:nr];
        
    }];
    [task resume];
    return task;
}

+ (BOOL)handleError:(NSError *)error dataType:(GOOGLE_DATA_TYPE)dataType {
    if (!error) return NO;
    
    switch (error.code) {
        case NSURLErrorCancelled: break;
        case NSURLErrorTimedOut:
            [self performDelegateSelector:@selector(requestTimedOut:) dataType:dataType parameter2:nil];
            break;
            
        case NSURLErrorNotConnectedToInternet:
            [self performDelegateSelector:@selector(requestFailedOffline:) dataType:dataType parameter2:nil];
            break;
            
        default:
            [self performDelegateSelector:@selector(requestFailed:) dataType:dataType parameter2:nil];
            break;
    }
    
    return YES;
}

+ (BOOL)handleResponse:(NSURLResponse *)response dataType:(GOOGLE_DATA_TYPE)dataType {
    if (((NSHTTPURLResponse *)response).statusCode == 200) return NO;
    [self performDelegateSelector:@selector(requestFailed:) dataType:dataType parameter2:nil];
    return YES;
}

+ (void)performDelegateSelector:(SEL)selector dataType:(GOOGLE_DATA_TYPE)dataType parameter2:(id)parameter2 {
    if (![[self manager].googleDelegate respondsToSelector:selector])
        return;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[[self manager].googleDelegate class] instanceMethodSignatureForSelector:selector]];
    [invocation retainArguments];
    invocation.target = [self manager].googleDelegate;
    invocation.selector = selector;
    [invocation setArgument:&dataType atIndex:2];
    if (parameter2)
        [invocation setArgument:&parameter2 atIndex:3];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [invocation invoke];
    }];
}

@end
