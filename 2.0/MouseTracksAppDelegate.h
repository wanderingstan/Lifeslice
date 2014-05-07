//
//  MouseTracksAppDelegate.h
//  MouseTracks
//
//  Created by Stan on 11/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <WebKit/WebKit.h>
#import "NSFileManager+DirectoryLocations.h"

BOOL g_verbose = NO;
BOOL g_quiet = NO;
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) (!g_quiet && printf(__VA_ARGS__))
#define verbose(...) (g_verbose && !g_quiet && fprintf(stderr, __VA_ARGS__))

// ImageSnap for Webcam use
#import "ImageSnap.h"

// SQLite stuff
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

// Autolaunch module
#import "LaunchAtLoginController.h"

// For getting idle time
#include <IOKit/IOKitLib.h>

// For relaunching
//#include "Sparkle.framework/Headers/SUUpdater.h"

static const int MIN_SCROLLEVENTS_FOR_SCROLL = 5;

@interface MouseTracksAppDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager; // lat/lon
	IBOutlet NSMenu *statusMenu; // menu
    NSStatusItem * statusItem; // menulet thing (i think)
    
    NSWindow *window;
    NSString *appDirectory;
    NSImage *menuIcon;
    IBOutlet WebView *theWebView;

    NSEventType lastEventType;
    int dragCount;
    int clickCount;
    int scrollCount;
    int cursorDistance;
    int keyCount;
    int keyDeleteCount;
    int keyDeleteRunCount;
    int keyZXCVCount;
    int wordCount;
    int wordKeyCount; // how many keys in a row that would be part of a word? 
    int currentScrollEventCount;
    int appSwitchCount;
    float lat;
    float lon;
    int lastSliceDay; // day of month of our last slice
    NSDate *lastSliceDate; // when did we make our last slice?
    NSPoint lastCursorPoint;
    int lastKeyCode; // code of last key that was pressed
    NSRunningApplication *currentApp;
    
    // daily totals
    int dayDragCount;
    int dayClickCount;
    int dayScrollCount;
    int dayCursorDistance;
    int dayKeyCount;
    int dayKeyDeleteCount;
    int dayKeyDeleteRunCount;
    int dayKeyZXCVCount;
    int dayWordCount;
    int dayCurrentScrollEventCount;
    int dayAppSwitchCount;
    
    FMDatabase *db; // our SQLite database

    IBOutlet id preferencesWindow;
    IBOutlet id browseSliceWindow;
    IBOutlet id liveStatsWindow;
    IBOutlet id aboutWindow;
    
    IBOutlet NSTextField *versionLabel;
    IBOutlet NSButton *myLaunchAtStartupCheckbox;
    
    IBOutlet NSImageView* webcamPreview;
    IBOutlet NSImageView* screenshotPreview;
    
}

@property NSEventType lastEventType;
@property int dragCount;
@property int clickCount;
@property int scrollCount;
@property int cursorDistance;
@property NSPoint lastCursorPoint;
@property int lastKeyCode;
@property int currentScrollEventCount;
@property int appSwitchCount;
@property (retain) NSRunningApplication *currentApp;
@property int keyCount;
@property int keyDeleteCount;
@property int keyDeleteRunCount;
@property int keyZXCVCount;
@property int wordCount;
@property int wordKeyCount; 
@property float lat; // our lat/lon coords
@property float lon; // our lat/lon coords
@property (retain) FMDatabase *db; // our SQLite database - Why can't I refer to this in more than one place without crashing?

// TODO: Add KeyReturnCount
@property int dayDragCount;
@property int dayClickCount;
@property int dayScrollCount;
@property int dayCursorDistance;
@property int dayKeyCount;
@property int dayKeyDeleteCount;
@property int dayKeyDeleteRunCount;
@property int dayKeyZXCVCount;
@property int dayWordCount;
@property int dayCurrentScrollEventCount;
@property int dayAppSwitchCount;
@property NSString *lastSliceIsoDate;

// We keep track of how many scroll events have contributed to current scroll gesture. If it's too short, we assume its a stupid case of momentum.

//-(int) targetMethod:(NSTimer *)myTimer;
- (void) handleEvent:(NSEvent *)incomingEvent;

- (IBAction)doLogNow:(id)pId;
- (void)uploadLogFile;
- (void)reportErrorAndUploadLog:(NSString*)message;

@property IBOutlet NSWindow *window;
    
@property (readwrite, retain) NSString *appDirectory;

- (IBAction)showPreferencesWindow:(id)pId;
- (IBAction)showBrowseSliceWindow:(id)pId;
- (IBAction)showLiveStatsWindow:(id)pId;
- (IBAction)showAboutWindow:(id)pId;
- (IBAction)showFeedbackWindow:(id)pId;
- (IBAction)showHomepage:(id)pId;

- (IBAction)deleteLatestSlice:(id)pId;
- (IBAction)revealFilesInFinder:(id)pId;
- (IBAction)importOldLifeSlice:(id)pId;
- (IBAction)toggleLaunchAtStartup:(id)sender;

- (IBAction)showLocationInMaps:(id)sender;
@end

