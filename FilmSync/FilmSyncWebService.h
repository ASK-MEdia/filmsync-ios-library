//
//  FilmSyncWebService.h
//  FilmSync
//
//  Created by Abdusha on 11/5/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilmSyncWebService : NSObject
{
    
}

#pragma mark -
#pragma mark Singleton Methods
+ (FilmSyncWebService *)sharedInstance;

#pragma mark -
#pragma mark APIs
-(void)setConnectionURL:(NSString *)url;
-(void)setAPISecret:(NSString *)ApiKey;
-(void)serverAPI_authenticateUsingAsync:(BOOL)isAsync andCompletionHandler:(void (^)(NSString *status))completionHandler;
-(void)serverAPI_getCard:(NSString *)cardID usingAsync:(BOOL)isAsync andCompletionHandler:(void (^)(NSDictionary* cardDict))completionHandler;



@end
