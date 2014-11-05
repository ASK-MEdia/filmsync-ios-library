//
//  FilmSync.m
//  FilmSync
//
//  Created by Abdusha on 9/11/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import "FilmSync.h"
#import "RIOInterface.h"


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

/*
int kFrequency_Zero_18000=18000;
int kFrequency_One_18100=18100;
int kFrequency_Two_18200=18200;
int kFrequency_Three_18300=18300;
int kFrequency_Four_18400=18400;
int kFrequency_Five_18500=18500;
int kFrequency_Six_18600=18600;
int kFrequency_Seven_18700=18700;
int kFrequency_Eight_18800=18800;
int kFrequency_Nine_18900=18900;
int kFrequency_Head_19000=19000;
int kFrequency_Separator_19100=19100;
int kFrequency_Tail_19200=19200;
int kFrequency_Correction_50=50;
*/

@interface FilmSync ()
{
    RIOInterface  *rioRef;
    
    //Frequency
    float currentFrequency;
    float previousFrequency;
    
    //Status Flags
    BOOL isListeningForSource;
    BOOL isSourceDetected;
    BOOL isSourceLost;
    BOOL isMarkerDetected;
    
    NSDate *sourceDetetionTime;
    NSTimer *sourceReadTimer;
    
    //to store listening frequencies followed by header
    NSMutableArray *frequencyArray;
    //to store markers strings (complete signal frequency sequence string)
    NSMutableArray *markerArray;
    
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
            [sharedFilmSyncManager setTimeOut:120]; //default timeout 2 minutes
            [sharedFilmSyncManager initializeRIO];
        }
        return sharedFilmSyncManager;
    }
}

- (void) initializeRIO
{
    currentFrequency = 0;
    
    rioRef = [RIOInterface sharedInstance];
    [rioRef setSampleRate:48000];
    [rioRef setFrequency:294];
    [rioRef initializeAudioSession];
}


- (void)startListener {
    
    isListeningForSource = YES;
	[rioRef startListening:self];
    [self.delegate listeningForSource];
    
    markerArray = [[NSMutableArray alloc] init];
    
}

- (void)stopListener {
	[rioRef stopListening];
    isListeningForSource = NO;
}

- (void)frequencyChangedWithValue:(float)newFrequency
{
    previousFrequency = currentFrequency;
	currentFrequency = newFrequency;
	[self performSelectorOnMainThread:@selector(checkFrequency) withObject:nil waitUntilDone:NO];
}

-(void)checkFrequency
{
    
    if (currentFrequency > (kFrequency_Zero_18000 - kFrequency_Correction_50) && currentFrequency != previousFrequency)
    {
        //if (isListeningForSource)
        {
            
            if (currentFrequency > (kFrequency_Head_19000 - kFrequency_Correction_50) && currentFrequency <= (kFrequency_Head_19000 + kFrequency_Correction_50))
            {
                [self.delegate sourceDetected];
                
                isListeningForSource = NO;
                isSourceDetected = YES;
                sourceDetetionTime = [NSDate date];
                
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
                sourceReadTimer = [NSTimer scheduledTimerWithTimeInterval:5.2f target:self selector:@selector(parseFrequencyArray) userInfo:nil repeats:NO];
            }
        }
        //else
        if (isSourceDetected)
        {
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
    
    //Using String
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
        
        
        [markerArray addObject:trimmedStr];
        [self.delegate markerDetected:trimmedStr];
    }
    else
    {
        [self.delegate sourceLost];
    }
    markerString = @"";
    [frequencyArray removeAllObjects];
    
    isListeningForSource = YES;
    isSourceDetected = NO;
}

-(void)AuthenticateWithServer
{
    NSURL *URL = [NSURL URLWithString:@"http://10.10.2.90/filmsync/auth.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      
                                      NSDictionary *jsonDict = [NSJSONSerialization
                                                                JSONObjectWithData:data
                                                                options:NSJSONReadingMutableLeaves
                                                                error:&error];
                                      
                                      NSLog(@"jsonDict :%@",jsonDict);
                                      NSLog(@"error :%@",error);
                                      
                                      if (!error)
                                      {
                                          NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
                                          [defaults setObject:@"135" forKey:@"projectCode"];
                                          [defaults synchronize];
                                      }
                                  }];
    
    [task resume];
    
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSLog(@"defaults :%@",[defaults stringForKey:@"projectCode"]);
    
    /*NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        //the NSData in the completion handler is where your data is downloaded.
    }];*/
}


//SDK Methods
//Returns the number of cards to be delivered during the entire duration of the source content (via JSON count of objects). Number
-(int) getTotalCards
{
    int cardsCount;
    
    
    return cardsCount;
}

//Returns the numerical id of current marker number detected from video source. A 32bit number . Returns null if no source detected.
-(NSString *)getCurrentCard
{
    if ([markerArray count] > 0)
    {
        NSString *currentCard = [markerArray lastObject];
        return currentCard;
    }
    else
    {
        return nil;
    }
}


//Returns the numerical id of previous marker number detected from the source content. This may not be in numerical order as user can move throughout the video source. If first marker, returns null.
-(NSString *)getPreviousCard
{
    if ([markerArray count] > 1)
    {
        NSString *prevCard = [markerArray objectAtIndex:([markerArray count] - 2)];
        return prevCard;
    }
    else
    {
        return nil;
    }
}


//Returns array of hzs of the last detected signal. Length max of 2.) ex. [18200, 19400]
-(NSArray *)getTonesDetected
{
    NSArray *tonesArray = [[NSArray alloc] init];
    
    return tonesArray;
}


//Returns the ID of the signal detected
-(NSString *)getSignalDetected
{
    NSString *signalStr = @"";
    
    return signalStr;
}


/** retrieve decode results for last scanned image/frame.
 * @returns the symbol set result container or NULL if no results are
 * available
 * @note the returned symbol set has its reference count incremented;
 * ensure that the count is decremented after use
 * @since 0.10
 */

/** process from the video stream until a result is available,
 * or the timeout (in milliseconds) expires.
 * specify a timeout of -1 to scan indefinitely
 * (zbar_processor_set_active() may still be used to abort the scan
 * from another thread).
 * if the library window is visible, video display will be enabled.
 * @note that multiple results may still be returned (despite the
 * name).
 * @returns >0 if symbols were successfully decoded,
 * 0 if no symbols were found (ie, the timeout expired)
 * or -1 if an error occurs
 */



@end
