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


@property (nonatomic, assign) id<FilmSyncDelegate> delegate; //FilmSync Delegate
@property (nonatomic, assign) float timeOut; //The specified time the app will continue to listen for source tones. Default, 120 seconds.

#pragma mark - Singleton

//Singleton object of class
+ (FilmSync*) sharedFilmSyncManager;

#pragma mark - Listener

//Frequency updater
- (void) frequencyChangedWithValue:(float)newFrequency;
// start filmSync listener
- (void) startListener;
// stop filmSync listener
- (void) stopListener;
// check listener state
- (BOOL) isListenerRunning;

#pragma mark - APIs
/** Sets the Base URL for API connection.
 * @param - base url
 */
-(void)setConnectionURL:(NSString *)url;

/** Sets the API Secret . Required. (licensing number).
 * @param - API Secret
 */
-(void)setAPISecret:(NSString *)ApiKey;

/** API to authenticate.
 * @return - completionHandler: status - "active" if the APISecret is vaild , otherwise "expired".
 * @note ensure that you have set the API SECRET before calling this;
 * this method will automaticaly called, when the session is expired.
 */
-(void)serverAPI_authenticate_CompletionHandler:(void (^)(NSString *status))completionHandler;

/** API to get card details.
 * @param - card id
 * @return - completionHandler: cardDict - Dictionary with CardData.
 * cardDict = nil , If the API Secret is invalid.
 */
-(void)serverAPI_getCard:(NSString *)cardID andCompletionHandler:(void (^)(NSDictionary* projectDict))completionHandler;

/** API to retrieve all cards for a projectID.
 * @param - project id
 * @return completionHandler: projectDict - Dictionary with Project details and Array of all cards.
 * projectDict = nil , If the API Secret is invalid.
 */
-(void)serverAPI_getAllCardsForProject:(NSString *)projectID andCompletionHandler:(void (^)(NSDictionary* cardsDict))completionHandler;


@end
