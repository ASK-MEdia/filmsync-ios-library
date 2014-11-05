//
//  FilmSyncWebService.m
//  FilmSync
//
//  Created by Abdusha on 11/5/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "FilmSyncWebService.h"


#define kFilmSyncWebServiceBaseURL
@implementation FilmSyncWebService
{
    NSString *apiSecret;
    NSString *sessionID;
    NSString *baseURL;
}



// *************** Singleton *********************

static FilmSyncWebService *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton Methods
+ (FilmSyncWebService *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[FilmSyncWebService alloc] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark -
#pragma mark APIs
-(void)setAPISecret:(NSString *)ApiKey
{
    apiSecret = ApiKey;
}
-(void)setConnectionURL:(NSString *)url
{
    baseURL = url;
}
-(void)serverAPI_authenticateUsingAsync:(BOOL)isAsync andCompletionHandler:(void (^)(NSString *status))completionHandler
{
    
}
-(void)serverAPI_getCard:(NSString *)cardID usingAsync:(BOOL)isAsync andCompletionHandler:(void (^)(NSDictionary* cardDict))completionHandler
{
    
    NSString *URLStr = [NSString stringWithFormat:@"http://filmsync.fingent.net/api/getacard/%@",cardID];
    NSURL *URL = [NSURL URLWithString:URLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    // Send a synchronous request
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    
    if (isAsync)
    {
        //Send Async
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (error == nil)
                                          {
                                              NSError *parseError = nil;
                                              NSDictionary *jsonDict = [NSJSONSerialization
                                                                        JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableLeaves
                                                                        error:&parseError];
                                              //NSLog(@"jsonDict :%@",jsonDict);
                                              
                                              if (parseError == nil)
                                              {
                                                  //[self newCardReceivedFromServer:jsonDict];
                                                  completionHandler(jsonDict);
                                              }
                                          }
                                          else
                                          {
                                              NSLog(@"getAllCardsForProjectFromServer - No Data Or Error Received");
                                          }
                                          
                                          
                                          NSLog(@"error :%@",error);
                                      }];
        
        [task resume];
    }
    else
    {
        NSData * data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        if (error == nil)
        {
            // Parse data here
            NSError *parseError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableLeaves
                                      error:&parseError];
            NSLog(@"jsonDict :%@",jsonDict);
            
            if (parseError == nil)
            {
                //[self newCardReceivedFromServer:jsonDict];
                completionHandler(jsonDict);
            }
        }
    }
  }


#pragma mark -



@end
