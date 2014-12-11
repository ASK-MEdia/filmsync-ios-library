## Introduction

FilmSync iOS Library covers tone detection and all remote API calls.


### Before You begin:

#### Before implementing the SDK, make sure you have the following,

* FilmSync iOS Library downloaded from filmSync site.
* API secret obtained from FilmSync Site (after licensing).


### Getting Started

There are three steps to getting started with the SDK.

* Add headers and libraries to your project.
* Initialize the listener and webservice.
* Receive delegates.

#### After completing these steps, you’ll be able to measure the following with FilmSync

* Start listening to the Audio sequence.
* Detect the embedded key codes within the Audio sequence.
* Recognize the Card ID from the combination of the different key codes.
* Using the Card ID, fetch card details from server.
* The fectched Card details contains a Project ID. Using this Project ID, fetch project details which contains all associated cards list from the server.
* Session handling for all remote API calls.


### Adding header files and configuring your project

* Download the FilmSync Library for iOS.
* Add the Library to you project.
* Add the following Frameworks to your project.
    - libc++.dylib
    - Accelerate.framework
    - AudioToolbox.framework
    - AVFoundation.framework
    - CoreAudio.framework
    - CoreFoundation.framework
    - Foundation.framework


### Integration


#### Initializing the FilmSync Marker Listener.

    add #import "FilmSync.h"

    FilmSync *filmSync = [FilmSync sharedFilmSyncManager];
    [filmSync setDelegate:self];
    [filmSync startListener];


#### Initializing the FilmSync Webservice.

    add #import "FilmSync.h"

    FilmSyncWebService *filmSyncAPI = [FilmSyncWebService sharedInstance];
    [filmSyncAPI setConnectionURL:@"http://filmsync.org"];
    [filmSyncAPI setAPISecret:@"XXXXXXXXXX"];


#### FilmSync Delegate methods

    //Dispatched when app is ready to find source audio
    -(void) listeningForSource

    //Dispatched once when a signal from an external source is detected for a specific sourceID. Will not be dispatched again till source is lost.
    -(void) sourceDetected

    //Dispatched once when no signal detected in timeOut duration.
    -(void) sourceLost

    //Dispatched when a proper signal is detected. Sends currentCard id.
    -(void) markerDetected:(NSString *)currentCardID




