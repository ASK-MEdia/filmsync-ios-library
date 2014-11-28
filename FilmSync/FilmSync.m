//
//  FilmSync.m
//  FilmSync
//
//  Created by Abdusha on 9/11/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "FilmSync.h"
#import "RIOInterface.h"


// Log include the function name and source code line number in the log statement
#ifdef FSW_DEBUG
#define FSWDebugLog(fmt, ...) NSLog((@"Func: %s, Line: %d, " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define FSWDebugLog(...)
#endif


//Constants
#define kFilmSyncPrefKeySessionID   @"filmSyncPrefKeySessionID"

#define kFrequency_Zero_18000       18000
#define kFrequency_One_18100        18100
#define kFrequency_Two_18200        18200
#define kFrequency_Three_18300      18300
#define kFrequency_Four_18400       18400
#define kFrequency_Five_18500       18500
#define kFrequency_Six_18600        18600
#define kFrequency_Seven_18700      18700
#define kFrequency_Eight_18800      18800
#define kFrequency_Nine_18900       18900
#define kFrequency_Head_19000       19000
#define kFrequency_Separator_19100  19100
#define kFrequency_Tail_19200       19200
#define kFrequency_Correction_50    50


@interface FilmSync ()
{
    RIOInterface  *rioRef;
    
    //Frequency
    float currentFrequency;
    float previousFrequency;
    
    //Status Flags
    BOOL isSourceDetected;
    BOOL isRunning;
    
    //Time of detection
    NSDate *sourceDetectionTime;
    //Timer for auto timeout
    NSTimer *sourceReadTimer;
    
    //Store listening frequencies followed by header
    NSMutableArray *frequencyArray;
    
    //Webserivce
    NSString *apiSecret;    // API Secret (licensing number)
    NSString *sessionID;    // Session ID , recived after authentication
    NSString *baseURL;      // base URL for API communication
    
}
- (void) initializeRIO;

@end

@implementation FilmSync
+ (FilmSync *) sharedFilmSyncManager
{
    static FilmSync *sharedFilmSyncManager;
    
    @synchronized(self)
    {
        if (!sharedFilmSyncManager) {
            sharedFilmSyncManager = [[FilmSync alloc] init];
            [sharedFilmSyncManager setTimeOut:5.2]; //default timeout 5.2 secs
            [sharedFilmSyncManager initializeRIO];
        }
        return sharedFilmSyncManager;
    }
}

#pragma mark -
#pragma mark FilmSync Listener Methods

// Initialize the listener
- (void) initializeRIO
{
    currentFrequency = 0;
    
    rioRef = [RIOInterface sharedInstance];
    isRunning = NO;
    [rioRef setSampleRate:48000];
    [rioRef setFrequency:294];
    [rioRef initializeAudioSession];
}

// Start Listener
- (void)startListener
{
    [rioRef startListening:self];
    isRunning = YES;
    [self.delegate listeningForSource];
}

//Stop Listener
- (void)stopListener
{
    [rioRef stopListening];
    isRunning = NO;
}

// Check Listener state
- (BOOL) isListenerRunning
{
    return isRunning;
}

// Frequency updated from listner engine
- (void)frequencyChangedWithValue:(float)newFrequency
{
    previousFrequency = currentFrequency;
    currentFrequency = newFrequency;
    [self performSelectorOnMainThread:@selector(checkFrequency) withObject:nil waitUntilDone:NO];
}

// check/filter/store for required frequencies
-(void)checkFrequency
{
    // Filter frequencies above 18000
    if (currentFrequency > (kFrequency_Zero_18000 - kFrequency_Correction_50) && currentFrequency != previousFrequency)
    {
        //Check for header tone
        if (currentFrequency > (kFrequency_Head_19000 - kFrequency_Correction_50) && currentFrequency <= (kFrequency_Head_19000 + kFrequency_Correction_50))
        {
            [self.delegate sourceDetected];
            
            isSourceDetected = YES;
            sourceDetectionTime = [NSDate date];
            
            if (frequencyArray !=nil)
            {
                frequencyArray = nil;
            }
            frequencyArray = [[NSMutableArray alloc] init];
            NSString *codeStr = [self codeForFrequency:currentFrequency];
            [frequencyArray addObject:[NSString stringWithFormat:@"%@",codeStr]];
            
            if ([sourceReadTimer isValid])
            {
                [sourceReadTimer invalidate];
                sourceReadTimer = nil;
            }
            sourceReadTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeOut target:self selector:@selector(parseFrequencyArray) userInfo:nil repeats:NO];
        }
    }
    
    if (isSourceDetected)
    {//Once header is received listening for the marker tones
        NSString *codeStr = [self codeForFrequency:currentFrequency];
        if (frequencyArray != nil)
        {
            [frequencyArray addObject:[NSString stringWithFormat:@"%@",codeStr]];
        }
        if (currentFrequency > (kFrequency_Tail_19200 - kFrequency_Correction_50) && currentFrequency < (kFrequency_Tail_19200 + kFrequency_Correction_50))
        {//Tail tone received
            [self parseFrequencyArray];
            
        }
        
    }
    
}
}

// Frequency mapper
-(NSString *)codeForFrequency:(float)frequency
{
    NSString *tone =@"";
    if (frequency > (kFrequency_Zero_18000 - kFrequency_Correction_50) && frequency < (kFrequency_Zero_18000 + kFrequency_Correction_50))
    {
        tone =@"0";
    }
    else if (frequency > (kFrequency_One_18100 - kFrequency_Correction_50) && frequency < (kFrequency_One_18100 + kFrequency_Correction_50))
    {
        tone =@"1";
    }
    else if (frequency > (kFrequency_Two_18200 - kFrequency_Correction_50) && frequency < (kFrequency_Two_18200 + kFrequency_Correction_50))
    {
        tone =@"2";
    }
    else if (frequency > (kFrequency_Three_18300 - kFrequency_Correction_50) && frequency < (kFrequency_Three_18300 + kFrequency_Correction_50))
    {
        tone =@"3";
    }
    else if (frequency > (kFrequency_Four_18400 - kFrequency_Correction_50) && frequency < (kFrequency_Four_18400 + kFrequency_Correction_50))
    {
        tone =@"4";
    }
    else if (frequency > (kFrequency_Five_18500 - kFrequency_Correction_50) && frequency < (kFrequency_Five_18500 + kFrequency_Correction_50))
    {
        tone =@"5";
    }
    else if (frequency > (kFrequency_Six_18600 - kFrequency_Correction_50) && frequency < (kFrequency_Six_18600 + kFrequency_Correction_50))
    {
        tone =@"6";
    }
    else if (frequency > (kFrequency_Seven_18700 - kFrequency_Correction_50) && frequency < (kFrequency_Seven_18700 + kFrequency_Correction_50))
    {
        tone =@"7";
    }
    else if (frequency > (kFrequency_Eight_18800 - kFrequency_Correction_50) && frequency < (kFrequency_Eight_18800 + kFrequency_Correction_50))
    {
        tone =@"8";
    }
    else if (frequency > (kFrequency_Nine_18900 - kFrequency_Correction_50) && frequency < (kFrequency_Nine_18900 + kFrequency_Correction_50))
    {
        tone =@"9";
    }
    else if (frequency > (kFrequency_Head_19000 - kFrequency_Correction_50) && frequency < (kFrequency_Head_19000 + kFrequency_Correction_50))
    {
        tone =@"H";
    }
    else if (frequency > (kFrequency_Separator_19100 - kFrequency_Correction_50) && frequency < (kFrequency_Separator_19100 + kFrequency_Correction_50))
    {
        tone =@"S";
    }
    else if (frequency > (kFrequency_Tail_19200 - kFrequency_Correction_50) && frequency < (kFrequency_Tail_19200 + kFrequency_Correction_50))
    {
        tone =@"T";
    }
    else
    {
        // NSLog(@"codeForFrequency else frqncy:%f ",frequency);
    }
    
    return tone;
}

// validate and process received frequency sequence (marker)
-(void)parseFrequencyArray;
{
    if ([sourceReadTimer isValid])
    {
        [sourceReadTimer invalidate];
        sourceReadTimer = nil;
    }
    
    //filtering, removing duplicates
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSString *prevValue =@"";
    for (NSString *str in frequencyArray)
    {
        if ([prevValue isEqualToString:str])
        {
            continue;
        }
        else
        {
            [tempArray addObject:str];
            prevValue = str;
        }
    }
    NSString *markerString = [[tempArray valueForKey:@"description"] componentsJoinedByString:@""];
    
    //Removing the Extra codes (Head/Separator/Tail) and Cleaning the marker.
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"HST"];
    NSString *trimmedStr = [[markerString componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
    
    int CodeLen = (int)[trimmedStr length];
    if (CodeLen == 12)
    {//Code length is correct , now Check for marker
        
        //Format the code with separator
        /*NSMutableString *codeString = [NSMutableString stringWithString:trimmedStr];
         [codeString insertString:@"." atIndex:3];
         [codeString insertString:@"." atIndex:7];
         [codeString insertString:@"." atIndex:11];*/
        
        [self.delegate markerDetected:trimmedStr];
    }
    else
    {
        [self.delegate sourceLost];
    }
    markerString = @"";
    [frequencyArray removeAllObjects];
    
    isSourceDetected = NO;
}


#pragma mark -
#pragma mark FilmSync Webservice APIs
// Set API secret from application
-(void)setAPISecret:(NSString *)ApiKey
{
    apiSecret = ApiKey;
    
    //Store in preferances
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    sessionID = [prefs stringForKey:kFilmSyncPrefKeySessionID];
    
    
}

// Set Base URL from application
-(void)setConnectionURL:(NSString *)url
{
    //Remove white space and "/" from end of URL
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([url hasSuffix:@"/"])
    {
        url = [url substringToIndex:[url length] - 1];
    }
    
    baseURL = url;
}

// API and validator for Authenticate
-(void)serverAPI_authenticate_CompletionHandler:(void (^)(NSString *status))completionHandler
{
    
    NSDictionary *authDict = [self getSessionIDFromServer:apiSecret];
    
    NSString *authStatus = @"";
    authStatus = [authDict objectForKey:@"status"];
    if ([authStatus isEqualToString:@"active"])
    {//got sessionID from server
        sessionID = [authDict objectForKey:@"sessionid"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:sessionID forKey:kFilmSyncPrefKeySessionID];
        [prefs synchronize];
        
        FSWDebugLog(@"Successful authentication");
    }
    else
    {//sessionID not received from server
        sessionID = nil;
        FSWDebugLog(@"Invalid API Secret");
    }
    //returning authentication status through completion handler
    completionHandler(authStatus);
}

// API and validator for Get Card details
-(void)serverAPI_getCard:(NSString *)cardID andCompletionHandler:(void (^)(NSDictionary* cardDict))completionHandler
{
    __block NSDictionary *cardDict = [self getCardFromServer:cardID];
    NSString *sessionStatus = [cardDict objectForKey:@"session"];
    if ([sessionStatus isEqualToString:@"active"])
    {//session is valid and card data received from server
        FSWDebugLog(@"valid session");
        completionHandler(cardDict);
    }
    else
    {//session expired
        FSWDebugLog(@"Re-authenticating session..");
        __block NSString *stat =@"";
        //try reauthenticating session
        [self serverAPI_authenticate_CompletionHandler:^(NSString *status)
         {
             stat = status;
         }];
        
        if ([stat isEqualToString:@"active"])
        {//session is valid and card data received from server
            cardDict = [self getCardFromServer:cardID];
            
        }
        else
        {//didn't get a valid session
            FSWDebugLog(@"Invalid sessionID and API Secret");
            cardDict = nil;
        }
        //returning cardDict through completion handler
        completionHandler(cardDict);
    }
}

// API and validator for Get all cards for project id
-(void)serverAPI_getAllCardsForProject:(NSString *)projectID andCompletionHandler:(void (^)(NSDictionary* projectDict))completionHandler
{
    __block NSDictionary *cardDict = [self getAllCardsForProject:projectID];
    NSString *sessionStatus = [cardDict objectForKey:@"session"];
    if ([sessionStatus isEqualToString:@"active"])
    {//session is valid and project data received from server
        FSWDebugLog(@"valid session");
        completionHandler(cardDict);
    }
    else
    {
        FSWDebugLog(@"Re-authenticating session..");
        __block NSString *stat =@"";
         //try reauthenticating session
        [self serverAPI_authenticate_CompletionHandler:^(NSString *status)
         {
             stat = status;
         }];
        
        if ([stat isEqualToString:@"active"])
        {//session is valid and project data received from server
            cardDict = [self getAllCardsForProject:projectID];
            
        }
        else
        {//didn't get a valid session
            FSWDebugLog(@"returning Invalid sessionID and API Secret");
            cardDict = nil;
        }
        //returning cardDict through completion handler
        completionHandler(cardDict);
    }
}

// Websevice : Authentication
-(NSDictionary *)getSessionIDFromServer:(NSString *)authKey
{
    NSString *URLStr = [NSString stringWithFormat:@"%@/api/handshake/%@",baseURL,apiSecret];
    NSURL *URL = [NSURL URLWithString:URLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    // Send a synchronous request
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    NSDictionary *jsonDict = nil;
    if (error == nil)
    {
        // Parse data here
        NSError *parseError = nil;
        jsonDict = [NSJSONSerialization
                    JSONObjectWithData:data
                    options:NSJSONReadingMutableLeaves
                    error:&parseError];
        if (parseError)
        {
            FSWDebugLog(@"Server Authentication parseError :%@",parseError);
        }
    }
    
    return jsonDict;
}

// Webservice : Get Card data
-(NSDictionary *)getCardFromServer:(NSString *)cardID
{
    NSString *URLStr = [NSString stringWithFormat:@"%@/api/getacard/%@/%@",baseURL,cardID,sessionID];
    NSURL *URL = [NSURL URLWithString:URLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSDictionary *jsonDict = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    if (error == nil)
    {
        // Parse data here
        NSError *parseError = nil;
        jsonDict = [NSJSONSerialization
                    JSONObjectWithData:data
                    options:NSJSONReadingMutableLeaves
                    error:&parseError];
        if (parseError == nil)
        {
            FSWDebugLog(@"Server getCardFromServer parseError :%@",parseError);
        }
    }
    return jsonDict;
}

// Websevice : get all cards for projectID
-(NSDictionary *)getAllCardsForProject:(NSString *)projectID
{
    NSString *URLStr = [NSString stringWithFormat:@"%@/api/getcardsforproject/%@/%@",baseURL,projectID,sessionID];
    NSURL *URL = [NSURL URLWithString:URLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSDictionary *jsonDict = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    if (error == nil)
    {
        // Parse data here
        NSError *parseError = nil;
        jsonDict = [NSJSONSerialization
                    JSONObjectWithData:data
                    options:NSJSONReadingMutableLeaves
                    error:&parseError];
        
        if (parseError != nil)
        {
            FSWDebugLog(@"Server getAllCardsForProject parseError :%@",parseError);
        }
    }
    return jsonDict;
}


@end
