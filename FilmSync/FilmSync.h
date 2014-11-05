//
//  FilmSync.h
//  FilmSync
//
//  Created by Abdusha on 9/11/14.
//  Copyright (c) 2014 Fingent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol FilmSyncDelegate
//SDK Events
@optional
//Dispatched when app is ready to find source audio
-(void) listeningForSource;
//Dispatched once when a signal from an external source is detected for a specific sourceID. Will not be dispatched again till source is lost.
-(void) sourceDetected;
//Dispatched once when no signal detected in timeOut duration.
-(void) sourceLost;
//Dispatched when a proper signal is detected. Sends currentCard id.
-(void) markerDetected:(NSString *)currentCardID;

@end


@interface FilmSync : NSObject


@property (nonatomic, assign) id<FilmSyncDelegate> delegate;
@property (nonatomic, retain) NSString *sourceID; //Unique identifier that relates directly to specific content source. Required. (licensing number)
@property (nonatomic, retain) NSURL *contentSourceURL; //Parent URL to source of content SON file (ex. http://docsinhand.com/api/12345.json)
@property (nonatomic, assign) long int timeOut; //The specified time the app will continue to listen for source tones. Default, 120 seconds.

+ (FilmSync*) sharedFilmSyncManager;
- (void) frequencyChangedWithValue:(float)newFrequency;
- (void) startListener;
- (void) stopListener;

//SDK Methods
//Returns the number of cards to be delivered during the entire duration of the source content (via JSON count of objects). Number
-(int) getTotalCards;
//Returns the numerical id of current marker number detected from video source. A 32bit number . Returns null if no source detected.
-(NSString *)getCurrentCard;
//Returns the numerical id of previous marker number detected from the source content. This may not be in numerical order as user can move throughout the video source. If first marker, returns null.
-(NSString *)getPreviousCard;
//Returns array of hzs of the last detected signal. Length max of 2.) ex. [18200, 19400]
-(NSArray *)getTonesDetected;
//Returns the ID of the signal detected
-(NSString *)getSignalDetected;




@end
