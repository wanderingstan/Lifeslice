//
//  MouseTracksAppDelegate.m
//  MouseTracks
//
//  Created by Stan on 11/21/12.
//  Copyright 2012 Stan James. All rights reserved.
//

#define DEBUG

#import "MouseTracksAppDelegate.h"
#import "ImageSnap.h"
#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation MouseTracksAppDelegate

@synthesize window;
@synthesize lastEventType;
@synthesize dragCount;
@synthesize clickCount;
@synthesize scrollCount;
@synthesize cursorDistance;
@synthesize keyCount;
@synthesize keyDeleteCount;
@synthesize keyZXCVCount;
@synthesize currentScrollEventCount;
@synthesize wordCount;
@synthesize wordKeyCount; // how many keys in a row that would be part of a word?
@synthesize lastCursorPoint;
@synthesize appSwitchCount;
@synthesize currentApp;
@synthesize lastSliceIsoDate;
@synthesize lat;
@synthesize lon;
@synthesize appDirectory;
@synthesize db;

@synthesize dayDragCount;
@synthesize dayClickCount;
@synthesize dayScrollCount;
@synthesize dayCursorDistance;
@synthesize dayKeyCount;
@synthesize dayKeyDeleteCount;
@synthesize dayKeyZXCVCount;
@synthesize dayWordCount;
@synthesize dayCurrentScrollEventCount;
@synthesize dayAppSwitchCount;

#pragma mark -
#pragma mark Application Starting and Stopping
#pragma mark -

/**
 * Setup
 */
-(void)awakeFromNib{
    NSLog(@"awakeFromNib start");
    
    NSLog(@"LifeSlice version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
    
    // Set up our menulet & icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"LifeSlice"];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
#ifdef RELEASE_TEST_BUILD
    //        NSString *path = [bundle pathForResource:@"IPMenuIconPieSlice" ofType:@"tif"];
    menuIcon = [NSImage imageNamed:@"MenuletIcon"];
#else
    // Show a different debug icon when we're testing/debugging/developing
    //        NSString *path = [bundle pathForResource:@"IPMenuIcon-Debug" ofType:@"tif"];
    menuIcon = [NSImage imageNamed:@"MenuletIconDebug"];
#endif
    
//    menuIcon = [[NSImage alloc] initWithContentsOfFile:path];
    
    [statusItem setImage:menuIcon];
    [statusItem setTitle:@""];

    // Figure out where out directory is
    // Get our destination directory
    self.appDirectory = [[NSFileManager defaultManager] applicationSupportDirectory];
    
    // Create our html working directory
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.appDirectory stringByAppendingPathComponent:@"html"] withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    
    // TODO: Instead of copying each html resource, get the path and do an rsync or other bulk copy...or use these files directly IN the bundle, with no copying.
    
    //    NSString *bundlePath = [bundle bundlePath];
    
    //    NSDate *result = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"slicebrowser-d3.html"] error:nil] fileCreationDate];
    
    // Copy our slicebrowser-d3.html
    
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"slicebrowser-d3.html"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"slicebrowser-d3" ofType:@"html"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"slicebrowser-d3.html"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy slicebrowser-d3.html: %@", error);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"slicebrowser-day-d3.html"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"slicebrowser-day-d3" ofType:@"html"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"slicebrowser-day-d3.html"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy slicebrowser-day-d3.html: %@", error);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"singlesliceviewer.html"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"singlesliceviewer" ofType:@"html"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"singlesliceviewer.html"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy singlesliceviewer.html: %@", error);
    }
    
    // Copy our jquery (see http://stackoverflow.com/a/4543314/59913 )
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"jquery-2.0.3.min.js"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"jquery-2.0.3.min" ofType:@"js"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"jquery-2.0.3.min.js"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy jquery-2.0.3.min.js: %@", error);
    }
    
    // Copy jquery map (what is this?)
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"jquery-2.0.3.min.map"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"jquery-2.0.3.min" ofType:@"map"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"jquery-2.0.3.min.map"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy jquery-2.0.3.min.map: %@", error);
    }

    // Copy our d3 (see http://stackoverflow.com/a/4543314/59913 )
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"d3.v3.min.js"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"d3.v3.min" ofType:@"js"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"d3.v3.min.js"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy d3.v3.min.js: %@", error);
    }
    
    // Copy Moment.js
    [[NSFileManager defaultManager] removeItemAtPath:[[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"moment.min.js"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[bundle pathForResource:@"moment.min" ofType:@"js"] toPath: [[self.appDirectory stringByAppendingPathComponent:@"html"] stringByAppendingPathComponent:@"moment.min.js"] error:&error];
    if (error != nil) {
        NSLog(@"Could not copy moment.min.js: %@", error);
    }
    
    NSLog(@"awakeFromNib exit");
}


- (BOOL)windowShouldClose:(NSNotification*)sender {
    return YES;
}

/**
 * Setup
 */
-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSLog(@"applicationDidFinishLaunching start");

#ifdef RELEASE_TEST_BUILD
    NSLog(@"Redirecting log to file.");
    // Log Redirect log to local file
    // http://stackoverflow.com/questions/429205/is-there-a-way-to-capture-the-ouput-of-nslog-on-an-iphone-when-not-connected-to
//    NSString *logPath = [[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"LifeSlice_%@.log", NSFullUserName()]];
//    NSString *logPath = [[[[NSFileManager defaultManager] applicationSupportDirectory] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"LifeSlice_%@.log", NSFullUserName()]];
    NSString *logPath = [self.appDirectory stringByAppendingPathComponent:@"LifeSlice_error_log.txt"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a",stderr);
#else
    NSLog(@"Not RELEASE_TEST_BUILD, so normal logging.");
#endif

    // Is the first time we're running?
    if (! [[NSUserDefaults standardUserDefaults] boolForKey:@"AlreadyBeenLaunched"]) {
        
        // This is our very first launch - Setting userDefaults for next time
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"AlreadyBeenLaunched"];
        
#ifdef RELEASE_TEST_BUILD
        // Ping home to record install for stats
        {
            // Create guid for this installation
            NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
            [[NSUserDefaults standardUserDefaults] setValue:guid forKey:@"InstallationGuid"];
            
            NSString* version= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSString* build= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://wanderingstan.com/apps/lifeslice/install.php?InstallationGuid=%@&build=%@&version=%@", guid, build, version]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 if ([data length] > 0 && error == nil) {
                     //[delegate receivedData:data];
                     NSLog(@"Received response. %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                 }
             }];
            
        }
        
        // Are we not set to auto-launch? Ask them about it.
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        if (! [launchController launchAtLogin]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"No thanks"];
            [alert setMessageText:@"Would you like to start LifeSlice automatically when you log in?"];
            [alert setInformativeText: [NSString stringWithFormat:@"This is reccomended to get a complete record of your computer usage. This can be changed at any time in the Preferences window.%@", @""]];
            [alert setAlertStyle:NSInformationalAlertStyle];
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                [launchController setLaunchAtLogin:YES];
            }
        }
#endif
    }

    // Check our permissions
    // See: http://stackoverflow.com/a/18121292/59913
    {
        NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES}; // This will automatically prompt for permissions if we don't have them.
        BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
        
        if (!accessibilityEnabled) {
            // Do something to ask them again? Gray out elements on live view?
        }
    }
    
    // Register for notifications
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Set our last date to null, in case someone selects "Delete last slice" when there is no last slice
    self->lastSliceIsoDate = @"";
    
	// Load prefs
	// http://pilhuhn.blogspot.com/2008/01/cocoa-preferences.html
    // http://stackoverflow.com/questions/2076816/how-to-register-user-defaults-using-nsuserdefaults-without-overwriting-existing
	NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:4], @"webcamInterval",
                          [NSNumber numberWithInt:4], @"screenshotInterval",
                          [NSNumber numberWithInt:0], @"locationInterval",
                          [NSNumber numberWithInt:1], @"mouseStatsInterval",
                          [NSNumber numberWithInt:1], @"keyboardStatsInterval",
                          [NSNumber numberWithInt:1], @"appStatsInterval",
                          [NSNumber numberWithInt:1], @"webStatsInterval",
                          [NSNumber numberWithInt:0], @"promptInterval",
                          [NSNumber numberWithInt:2], @"webcamMaxSize",
                          [NSNumber numberWithInt:2], @"screenShotMaxSize",
                          nil
                          ];
	[preferences registerDefaults:dict];
    
    // Set up our webcam directories if needed
    NSError * webcamError = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.appDirectory stringByAppendingPathComponent:@"webcam"] withIntermediateDirectories:YES attributes:nil error:&webcamError];
    if (webcamError != nil) {
        NSLog(@"ERROR: error creating directory: %@", webcamError);
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.appDirectory stringByAppendingPathComponent:@"webcam_thumbs"] withIntermediateDirectories:YES attributes:nil error:&webcamError];
    if (webcamError != nil) {
        NSLog(@"ERROR: error creating directory: %@", webcamError);
    }

    // Set up our screenshot directory if needed
    NSError * screenshotError = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.appDirectory stringByAppendingPathComponent:@"screenshot"] withIntermediateDirectories:YES attributes:nil error:&screenshotError];
    if (screenshotError != nil) {
        NSLog(@"ERROR: error creating directory: %@", screenshotError);
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.appDirectory stringByAppendingPathComponent:@"screenshot_thumbs"] withIntermediateDirectories:YES attributes:nil error:&screenshotError];
    if (screenshotError != nil) {
        NSLog(@"ERROR: error creating directory: %@", screenshotError);
    }
    
#pragma mark - Set up SQL tables
    
    self.db = [FMDatabase databaseWithPath:[self.appDirectory stringByAppendingPathComponent:@"lifeslice.sqlite"]];
    if (![self.db open]) {
        NSLog(@"Could not open db.");
        // TODO: Bigger error message here!
    }
    else {
        // Retain the DB connection for use throughout life of our app
        
        // Set up our database if needed, including newly added columns
        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS webcam (timestamp INTEGER, datetime TEXT, filename TEXT, interval INTEGER)"];
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS webcam_datetime_index ON webcam (datetime)"];
        
        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS screenshot (timestamp INTEGER, datetime TEXT, filename TEXT, interval INTEGER, filename2 TEXT)"];
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS screenshot_datetime_index ON screenshot (datetime)"];
        [self.db executeUpdate:@"ALTER TABLE screenshot ADD COLUMN filename TEXT"];
        [self.db executeUpdate:@"ALTER TABLE screenshot ADD COLUMN filename2 TEXT"];
        
        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS location (timestamp INTEGER, datetime TEXT, lat DOUBLE, lon DOUBLE)"];
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS location_datetime_index ON location (datetime)"];

        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS mouse (timestamp INTEGER, datetime TEXT, interval INTEGER, clickCount INTEGER, dragCount INTEGER, scrollCount INTEGER, cursorDistance INTEGER)"];
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS mouse_datetime_index ON mouse (datetime)"];
        
        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS keyboard (timestamp INTEGER, datetime TEXT, interval INTEGER, keyCount INTEGER, keyDeleteCount INTEGER, keyZXCVCount INTEGER, wordCount INTEGER)"];
        [self.db executeUpdate:@"ALTER TABLE keyboard ADD COLUMN keyDeleteRunCount INTEGER"];
        
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS keyboard_datetime_index ON keyboard (datetime)"];
        
        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS app (timestamp INTEGER, datetime TEXT, interval INTEGER, idleSecs INTEGER, appSwitchCount INTEGER, currentApp TEXT)"];
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS app_datetime_index ON app (datetime)"];
        [self.db executeUpdate:@"ALTER TABLE app ADD COLUMN serialNumber TEXT"];

        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS web (timestamp INTEGER, datetime TEXT, interval INTEGER, currentURL TEXT, browserTabCount INTEGER)"];
        
        [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS prompt (timestamp INTEGER, datetime TEXT, interval INTEGER, answer TEXT)"];
        [self.db executeUpdate:@"CREATE INDEX IF NOT EXISTS prompt_datetime_index ON prompt (datetime)"];

        
        // Get total values for today (in case we quit and re-launched later in day)
        NSDate* now = [NSDate date];
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy'-'MM'-'dd'%'"];
        NSString *nowDateIsoString = [f stringFromDate:now];
        
        FMResultSet *rs1 = [db executeQuery:[NSString stringWithFormat:@"SELECT SUM(keyCount) AS dayKeyCount, SUM(keyDeleteCount) AS dayKeyDeleteCount, SUM(keyZXCVCount) AS dayKeyZXCVCount, SUM(wordCount) AS dayWordCount FROM keyboard WHERE datetime LIKE '%@';", nowDateIsoString]];
        while ([rs1 next]) {
            self.dayKeyCount = [rs1 intForColumn:@"dayKeyCount"];
            self.dayKeyDeleteCount = [rs1 intForColumn:@"dayKeyDeleteCount"];
            self.dayKeyZXCVCount = [rs1 intForColumn:@"dayKeyZXCVCount"];
            self.dayWordCount = [rs1 intForColumn:@"dayWordCount"];
        }
        FMResultSet *rs2 = [db executeQuery:[NSString stringWithFormat:@"SELECT SUM(appSwitchCount) AS dayAppSwitchCount FROM app WHERE datetime LIKE '%@';", nowDateIsoString]];        
        while ([rs2 next]) {
            self.dayAppSwitchCount = [rs2 intForColumn:@"dayAppSwitchCount"];
        }
        FMResultSet *rs3 = [db executeQuery:[NSString stringWithFormat:@"SELECT SUM(clickCount) AS dayClickCount,SUM(dragCount) AS dayDragCount,SUM(scrollCount) AS dayScrollCount, SUM(cursorDistance) AS dayCursorDistance FROM mouse WHERE datetime LIKE '%@';", nowDateIsoString]];
        while ([rs3 next]) {
            self.dayClickCount = [rs3 intForColumn:@"dayClickCount"];
            self.dayDragCount = [rs3 intForColumn:@"dayDragCount"];
            self.dayScrollCount = [rs3 intForColumn:@"dayScrollCount"];
            self.dayCursorDistance = [rs3 intForColumn:@"dayCursorDistance"];
        }
        
        [rs1 close];
        [rs2 close];
        [rs3 close];
        [self.db close];
    }
    
    // TODO: Load last-taken images for showing in live stats
    // http://stackoverflow.com/questions/3103840/how-do-you-load-a-local-jpeg-or-png-image-file-into-an-iphone-app
    
    
	// Reset location values
	self.lat = 0.0;
	self.lon = 0.0;
    
	// Set up timer to fire every minute
	[NSTimer scheduledTimerWithTimeInterval:60
									 target:self
								   selector:@selector(minuteTimerCallback:)
								   userInfo:nil
									repeats:YES
	 ];
	
	// List of possible events to listen for:
	// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSEvent_Class/Reference/Reference.html#//apple_ref/doc/constant_group/NSEventMaskFromType
    
    // Monitor local events (in our app)
	[NSEvent addLocalMonitorForEventsMatchingMask:(NSMouseMovedMask|NSLeftMouseDraggedMask|NSLeftMouseUpMask|NSKeyDownMask|NSScrollWheelMask) handler:^NSEvent* (NSEvent *incomingEvent) {
		[self handleEvent:incomingEvent];
        return incomingEvent;
	}];
    // Monitor global events (in other apps)
	[NSEvent addGlobalMonitorForEventsMatchingMask:(NSMouseMovedMask|NSLeftMouseDraggedMask|NSLeftMouseUpMask|NSKeyDownMask|NSScrollWheelMask) handler:^(NSEvent *incomingEvent) {
		[self handleEvent:incomingEvent];
	}];
    // Montior changes to current application
    NSNotificationCenter * center =  [[NSWorkspace sharedWorkspace]
                                      notificationCenter];
    [center addObserver:self selector:@selector(applicationActivatedCallback:)
                   name:NSWorkspaceDidActivateApplicationNotification object:nil ];
    
    // For testing, always show about window on startup
//    [aboutWindow setLevel:NSFloatingWindowLevel]; // keep it on top
//    [NSApp activateIgnoringOtherApps:YES];
    
    // See if there is old data (from cron version) to import
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Lifeslice"]]) {
        // They used the old version at some point
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Lifeslice/data/SUCCESSFULLY_IMPORTED_FLAG.txt"]]) {
            // They imported their old data -- good for them.
        }
        else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"Later"];
            [alert addButtonWithTitle:@"Never"];
            [alert setMessageText:@"Would you like to import your old LifeSlice data?"];
            [alert setInformativeText: [NSString stringWithFormat:@"Thank you for using the old script-based version of LifeSlice.\n\nIt could take a couple minutes to import your images and data into the new version. Would you like to do this now?%@", @""]];
            [alert setAlertStyle:NSInformationalAlertStyle];
            
            switch ([alert runModal]) {
                case NSAlertFirstButtonReturn:
                    [self importOldLifeSliceRun];
                    break;
                case NSAlertThirdButtonReturn:
                    // Write our flag file to prevent future buggings.
                    [@"" writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Lifeslice/data/SUCCESSFULLY_IMPORTED_FLAG.txt"]
                              atomically:NO
                                encoding:NSStringEncodingConversionAllowLossy
                                   error:nil];
                    NSAlert *alert2 = [[NSAlert alloc] init];
                    [alert2 addButtonWithTitle:@"OK"];
                    [alert2 setMessageText:@"You can import your old data later by going to Preferences->Files->Import Old LifeSlice Data."];
                    [alert2 setAlertStyle:NSInformationalAlertStyle];
                    [alert2 runModal];
                    break;
            }
//            if ([alert runModal] == NSAlertFirstButtonReturn) {
//                [self importOldLifeSliceRun];
//            }
        }
    }
    
    #ifdef RELEASE_TEST_BUILD
        // See if we shut down nicely last time
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDirectory stringByAppendingPathComponent:@".APPLICATION_RUNNING_FLAG.txt"]]) {
            [self reportErrorAndUploadLog:@"LifeSlice did not close correctly last time. Would you like to send an error report?"];
        }
    #endif
 
    // Write a flag file to indicate that we are running
    [@"" writeToFile:[self.appDirectory stringByAppendingPathComponent:@".APPLICATION_RUNNING_FLAG.txt"]
          atomically:NO
            encoding:NSStringEncodingConversionAllowLossy
               error:nil];
    
    // Set up location monitoring
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.purpose = @"To know where the computer is. This information is only ever stored locally."; // Not sure where this is shown.

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"locationInterval"] != 0) {
        // If user is tracking location, we do this now to prompt user to give permission before time officially clicks over
        [locationManager startUpdatingLocation];
    }

    NSLog(@"Done with applicationDidFinishLaunching");
}

/**
 * Relaunch the application
 */
//- (IBAction)restartApplication:(id)sender;
//{
//    NSString *launcherSource = [[NSBundle bundleForClass:[SUUpdater class]]  pathForResource:@"relaunch" ofType:@""];
//    NSString *launcherTarget = [NSTemporaryDirectory() stringByAppendingPathComponent:[launcherSource lastPathComponent]];
//    NSString *appPath = [[NSBundle mainBundle] bundlePath];
//    NSString *processID = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
//    
//    [[NSFileManager defaultManager] removeItemAtPath:launcherTarget error:NULL];
//    [[NSFileManager defaultManager] copyItemAtPath:launcherSource toPath:launcherTarget error:NULL];
//	
//    [NSTask launchedTaskWithLaunchPath:launcherTarget arguments:[NSArray arrayWithObjects:appPath, processID, nil]];
//    [NSApp terminate:sender];
//
//}

/**
 * Confirm with user, then quit the app
 */
- (IBAction)quitApplication:(id)pId;
{
    
#ifdef RELEASE_TEST_BUILD
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Quit"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Are you sure you want to quit?"];

    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    if ([launchController launchAtLogin]) {
        [alert setInformativeText: @"No statistics will be logged while LifeSlice is off. LifeSlice is currently set to start automatically when you next log in."];
    }
    else {
        [alert setInformativeText: @"No statistics will be logged while LifeSlice is off, and LifeSlice is not currently set to automatically start."];
    }
    [alert setAlertStyle:NSInformationalAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        // confirmed. Quit the app.
        [[NSApplication sharedApplication] terminate:nil];
    }
#else
    [[NSApplication sharedApplication] terminate:nil];
#endif
    
}

/**
 * Application ending
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Clear our running flag to indication we're ending nicely
    [[NSFileManager defaultManager] removeItemAtPath:[self.appDirectory stringByAppendingPathComponent:@".APPLICATION_RUNNING_FLAG.txt"] error:nil];
    
    // These were commented out, not sure why. watch for future problems here.
    [locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark Error reporting

/**
 * Tell the user about an error and give option to upload error log.
 */
- (void)reportErrorAndUploadLog:(NSString*)message
{
    NSLog(@"Reported error: %@",message);
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Send Error Report"];
    [alert addButtonWithTitle:@"Skip"];
    [alert setMessageText:message];
    [alert setInformativeText: @"Sending an error report will help fix this problem in future versions. However, it will send some basic information about your computer usage while LifeSlice ran. No webcam images, screenshots, or location data are sent."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self uploadLogFile];
    }
}

/**
 * Upload our log file to LifeSlice server for analysis
 */
- (void)uploadLogFile
{
    // upload our logs to home server for debugging
    // http://stackoverflow.com/questions/12420453/objective-c-post-request-not-sending-data
    
    NSString *logPath = [self.appDirectory stringByAppendingPathComponent:@"LifeSlice_error_log.txt"];
    NSString *str = [[NSString alloc]
                     initWithContentsOfFile:logPath
                     encoding:NSUTF8StringEncoding
                     error:nil];
    NSData* theData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    if (str == nil) {
        NSLog(@"Could not read LifeSlice_error_log.txt. Skipping sending of error report");
    }
    else {
        NSString *urlString = @"http://wanderingstan.com/lifeslice/submit-error-report.php";
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]   dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", @"LifeSlice_error_log.txt"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:theData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Server response: %@", returnString);
    }
}


#pragma mark -
#pragma mark Auto-start on Login

/**
 * Toggle the application launching at startup
 * Ref: https://github.com/biocross/LaunchAtLoginController--with-ARC-
 */
- (IBAction)toggleLaunchAtStartup:(id)sender {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:([myLaunchAtStartupCheckbox state] == NSOnState)];
}

#pragma mark -
#pragma mark Log our data
#pragma mark -

- (IBAction)doLogNow:(id)pId {
    NSLog(@"Record Slice Now - triggering log of all dimensions.");
    [self minuteTimerCallback:nil];
}

- (void)applicationActivatedCallback:(NSNotification *)notification {
    self.currentApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
//    NSString * bob = [[[notification userInfo] objectForKey:NSWorkspaceApplicationKey] bundleIdentifier] ;
    self.appSwitchCount++;
    self.dayAppSwitchCount++;
}

//	NSPoint mouseLoc;
//	mouseLoc = [NSEvent mouseLocation]; //get current mouse position
//	NSLog(@"Timer update: Mouse location: %f %f", mouseLoc.x, mouseLoc.y);

-(int) minuteTimerCallback:(NSTimer *)myTimer {
	
    // If we're not passed a timer,@ that's our signal to do ALL logging for debug.
    int doAll = (myTimer == nil);
    
    // Set up SQLite
    NSLog(@"Connecting to Sqlite database");
    self.db = [FMDatabase databaseWithPath:[self.appDirectory stringByAppendingPathComponent:@"lifeslice.sqlite"]];
    if (![self.db open]) {
        NSLog(@"ERROR: Could not open db.");
        return 0;
    }
    
	// Set up our array of column titles in log file
	NSMutableArray *logColumnNames = [[NSMutableArray alloc]init];
	// Create dictionary of log values generated in this callback (keys are columns)
	NSMutableDictionary *logColumnValues = [NSMutableDictionary dictionary];
    
	// Our little mapping from selected index (GUI) to actual minutes
	// (Really scary how verbose objective C is. Holy crap!)
	// minuteMapping = [(0,9999),(1,5),(2,10),(3,30),(4,60)]
	NSMutableDictionary *minuteMapping = [NSMutableDictionary dictionary];
	[minuteMapping setObject: [NSNumber numberWithInt:9999] forKey: [NSNumber numberWithInt:0]];
	[minuteMapping setObject: [NSNumber numberWithInt:5   ] forKey: [NSNumber numberWithInt:1]];
	[minuteMapping setObject: [NSNumber numberWithInt:10  ] forKey: [NSNumber numberWithInt:2]];
	[minuteMapping setObject: [NSNumber numberWithInt:30  ] forKey: [NSNumber numberWithInt:3]];
	[minuteMapping setObject: [NSNumber numberWithInt:60  ] forKey: [NSNumber numberWithInt:4]];
    
	// Figure out what time and date it is
	NSDate* now = [NSDate date];
    //int hour = 23 - [[now dateWithCalendarFormat:nil timeZone:nil] hourOfDay];
	int min = [[now dateWithCalendarFormat:nil timeZone:nil] minuteOfHour];
    
#ifndef RELEASE_TEST_BUILD
    // if we are testing, shift our timer forward by a minute so it doesn't collide with running production timer
    NSLog(@"Shifting time forward one minute for testing.");
    min = min-1;
#endif
    
    //int sec = 59 - [[now dateWithCalendarFormat:nil timeZone:nil] secondOfMinute];
	// dumb hack to handle our on-hour intervals
	if (min == 0) {
		min = 60;
	}
	// Format time/date into filename formats
	// http://stackoverflow.com/questions/6667829/nsdateformatter-and-strings-with-timezone-format-hhmm
    // ISO datetime
	NSDateFormatter *f3 = [[NSDateFormatter alloc] init];
	[f3 setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':00Z'Z"];
	NSString *nowIsoString = [f3 stringFromDate:now];
    // Filename datetime
	NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
	[f2 setDateFormat:@"yyyy'-'MM'-'dd'T'HH'-'mm'-00Z'Z"];
	NSString *s = [f2 stringFromDate:now];
    // Excel/CSV datetime
    NSDateFormatter *f1 = [[NSDateFormatter alloc] init];
	[f1 setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':00"];
	NSString *nowExcelString = [f1 stringFromDate:now];
    
    // If we are on a different day, reset all our totals!
    if (([[now dateWithCalendarFormat:nil timeZone:nil] dayOfMonth] != lastSliceDay) && (lastSliceDay>0)) {
        self.dayDragCount = 0;
        self.dayClickCount = 0;
        self.dayScrollCount = 0;
        self.dayCursorDistance = 0;
        self.dayKeyCount = 0;
        self.dayKeyDeleteCount = 0;
        self.dayKeyZXCVCount = 0;
        self.dayWordCount = 0;
        self.dayCurrentScrollEventCount = 0;
        self.dayAppSwitchCount = 0;
        
        
        [self showYesterdaySummaryNotification];
        
        // Reset log file (so it doesn't get too big)
        NSString *logPath = [self.appDirectory stringByAppendingPathComponent:@"LifeSlice_error_log.txt"];
        [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
        
    }
    lastSliceDay = [[now dateWithCalendarFormat:nil timeZone:nil] dayOfMonth];

    // date/time columns
    [logColumnNames addObject:@"iso datetime"];
    [logColumnValues setObject: nowIsoString  forKey: @"iso datetime"];
    [logColumnNames addObject:@"excel datetime"];
    [logColumnValues setObject: nowExcelString  forKey: @"excel datetime"];

    // http://stackoverflow.com/questions/1692555/get-current-focused-window-id-using-objective-c
    // http://stackoverflow.com/questions/12673757/how-to-check-if-my-app-is-running-in-full-screen-mode
    // MAYBE: we could/should also check if the screen has changed (much) since last time. no change = we're probably idle (but clock will change..)
    BOOL isFullScreen = ([[[NSApplication sharedApplication] keyWindow] styleMask] & NSFullScreenWindowMask);
    if (isFullScreen){
        NSLog(@"We are fullscreen, so assuming that user is there watching a movie or something.");
    }
    BOOL userIsIdle = ((SystemIdleTime() > (60 * 5))) && (!isFullScreen); // for now we hardcode idle to mean "nothing for 5 minutes"
    
    //
    // Log our various data sources (webcam, screenshot, keyboard stats, etc...)
    //
    
#pragma mark Log webcam picture
    
	[logColumnNames addObject:@"webcamShotFilename"];
	[logColumnNames addObject:@"webcamIntervalMins"];
	int webcamIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"webcamInterval"]] integerValue];
	BOOL doWebcam = (!(min % webcamIntervalMins));
	if ((doWebcam && !userIsIdle) || doAll) {
        // get shot from webcam using imagesnap 
        NSString *webcamShotFilename = [NSString stringWithFormat:@"face_%@.jpg", s];
        NSString *webcamShotPathname = [[self.appDirectory stringByAppendingPathComponent:@"webcam"] stringByAppendingPathComponent:webcamShotFilename];
        
        [ImageSnap saveSnapshotFrom:[ImageSnap defaultVideoDevice] toFile:webcamShotPathname withWarmup:@1.0];

        int webcamMaxSize = [[@[@0,@1280,@1024,@640] objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"webcamMaxSize"] integerValue]] integerValue]; //webcamSizeOptions[selectedIndex];
        if (webcamMaxSize > 0)
        {
            // Resize image TODO: Should be done in native code
            NSString *command = [NSString stringWithFormat:@"/usr/bin/sips -Z %d '%@'", webcamMaxSize, webcamShotPathname];
            system([command cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
        // save for csv output
        {
            [logColumnValues setObject: webcamShotFilename  forKey: @"webcamShotFilename"];
            [logColumnValues setObject: [NSString stringWithFormat:@"%u",webcamIntervalMins] forKey: @"webcamIntervalMins"];
            // write to sql
            if (![self.db executeUpdate:@"INSERT INTO webcam (timestamp,datetime,filename,interval) VALUES (?, ?, ?, ?)" ,
                  [NSNumber numberWithInt:0],
                  nowIsoString,
                  webcamShotFilename,
                  [NSNumber numberWithInt:webcamIntervalMins]
                  ]) {
                NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
            };
        }
        
        // Create thumbnail version
        {
            NSString *webcamShotThumbFilename = [NSString stringWithFormat:@"face_%@.jpg", s];
            NSString *webcamShotThumbPathname = [[self.appDirectory stringByAppendingPathComponent:@"webcam_thumbs"] stringByAppendingPathComponent:webcamShotThumbFilename];
            NSString *webcamMakeThumbCmd = [NSString stringWithFormat:@"/usr/bin/sips --resampleWidth 120 '%@' --out '%@'", webcamShotPathname, webcamShotThumbPathname];
            NSLog(@"ss %@",webcamShotThumbPathname);
            NSLog(@"ss %@",webcamMakeThumbCmd);
            system([webcamMakeThumbCmd cStringUsingEncoding:NSUTF8StringEncoding]);
        
            // show in live stats & menubar
            NSImage *webcamImage = [[NSImage alloc] initWithContentsOfFile:webcamShotThumbPathname];
            [webcamPreview setImage:webcamImage];
            [webcamMenuItem setImage:webcamImage];
            [webcamMenuItem setHidden:NO];
        }
        
        
        lastSliceIsoDate = [f3 stringFromDate:now];
        lastSliceDate = now;
	}
	
#pragma mark Log screenshot
	[logColumnNames addObject:@"screenShotFilename"];
	[logColumnNames addObject:@"screenshotIntervalMins"];
	int screenshotIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"screenshotInterval"]] integerValue];
	BOOL doScreenshot = (!(min % screenshotIntervalMins));
	if ((doScreenshot && !userIsIdle) || doAll) {
        
        // Get the screenshot
        // TODO: Use "real" method to get screenshot, no helper app
        NSString *screenShotFilename = [NSString stringWithFormat:@"screen_%@.png", s];
        NSString *screenShotPathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot"] stringByAppendingPathComponent:screenShotFilename];
        NSString *screenShot2Filename = [NSString stringWithFormat:@"screen_2_%@.png", s]; // for 2nd monitor
        NSString *screenShot2Pathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot"] stringByAppendingPathComponent:screenShot2Filename];
        NSString *screenShotCmd = [NSString stringWithFormat:@"/usr/sbin/screencapture -C -x '%@' '%@'", screenShotPathname, screenShot2Pathname];
        system([screenShotCmd cStringUsingEncoding:NSUTF8StringEncoding]);
        // see if there actually was a second screen by testing for existance of that screenshot file
        if(![[NSFileManager defaultManager] fileExistsAtPath:screenShot2Pathname]) {
            screenShot2Filename = nil;
        }
        
        int screenShotMaxSize = [[@[@0, @1440 , @1280, @640] objectAtIndex: [[[NSUserDefaults standardUserDefaults] objectForKey:@"screenShotMaxSize"] integerValue]] integerValue];
        if (screenShotMaxSize > 0)
        {
            // Resize image TODO: Should be done in native code
            NSString *command = [NSString stringWithFormat:@"/usr/bin/sips -Z %d '%@'", screenShotMaxSize, screenShotPathname];
            system([command cStringUsingEncoding:NSUTF8StringEncoding]);
        }

        // save for csv output
        [logColumnValues setObject: screenShotFilename  forKey: @"screenShotFilename"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",screenshotIntervalMins] forKey: @"screenshotIntervalMins"];
        // write to sql
        if (![self.db executeUpdate:@"INSERT INTO screenshot (timestamp,datetime,filename,interval,filename2) VALUES (?, ?, ?, ?, ?)" ,
            [NSNumber numberWithInt:0],
            nowIsoString,
            screenShotFilename,
            [NSNumber numberWithInt:screenshotIntervalMins],
            screenShot2Filename
        ]) {
            NSLog(@"ERROR:screenshot: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        
        // Create thumbnail version
        NSString *screenShotThumbFilename = [NSString stringWithFormat:@"screen_%@.png", s];
        NSString *screenShotThumbPathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot_thumbs"] stringByAppendingPathComponent:screenShotThumbFilename];
        NSString *screenShotMakeThumbCmd = [NSString stringWithFormat:@"/usr/bin/sips --resampleWidth 240 '%@' --out '%@'",screenShotPathname, screenShotThumbPathname];
        system([screenShotMakeThumbCmd cStringUsingEncoding:NSUTF8StringEncoding]);
        if([[NSFileManager defaultManager] fileExistsAtPath:screenShot2Pathname]) {
            // thumbnail of second screen, if needed
            NSString *screenShot2ThumbFilename = [NSString stringWithFormat:@"screen_2_%@.png", s];
            NSString *screenShot2ThumbPathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot_thumbs"] stringByAppendingPathComponent:screenShot2ThumbFilename];
            NSString *screenShot2MakeThumbCmd = [NSString stringWithFormat:@"/usr/bin/sips --resampleWidth 240 '%@' --out '%@'",screenShot2Pathname, screenShot2ThumbPathname];
            system([screenShot2MakeThumbCmd cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
        // show in live stats
        if ([[NSFileManager defaultManager] fileExistsAtPath:screenShotThumbPathname]) {
            NSImage *screenshotImage = [[NSImage alloc] initWithContentsOfFile:screenShotThumbPathname] ;
            [screenshotPreview setImage:screenshotImage];
            [screenshotMenuItem setImage:screenshotImage];
            [screenshotMenuItem setHidden:NO];
        }
    
    }
    
#pragma mark Log geo-location
    
	[logColumnNames addObject:@"lat"];
	[logColumnNames addObject:@"lon"];
	[logColumnNames addObject:@"locationIntervalMins"];
	int locationIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"locationInterval"]] integerValue];
    // special step: one minute before we log location, we need to turn location monitoring on
	BOOL doLocationStart = (!((min+1) % locationIntervalMins));
    if (doLocationStart){
        [locationManager startUpdatingLocation];
        NSLog(@"One minute early start of locationManager.");
    }
    // back to normal logging..
	BOOL doLocation = (!(min % locationIntervalMins));
	if (doLocation || doAll) {
        // save for csv output
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",locationIntervalMins] forKey: @"locationIntervalMins"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%.6f",[self lat]] forKey: @"lat"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%.6f",[self lon]] forKey: @"lon"];
        // write to sql
        if (![self.db executeUpdate:@"INSERT INTO location (timestamp,datetime,lat,lon) VALUES (?, ?, ?, ?)",
            [NSNumber numberWithInt:0],
            nowIsoString,
            [NSNumber numberWithFloat:self.lat],
            [NSNumber numberWithFloat:self.lon]
        ]) {
            NSLog(@"geo-location stats: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        // stop updating location until we need it again
        [locationManager stopUpdatingLocation];
	}
    if (!doLocation) {
        self.lat = 0.00;
        self.lon = 0.00;
    }
    
    
#pragma mark Log mouse stats
	[logColumnNames addObject:@"mouseStatsIntervalMins"];
	[logColumnNames addObject:@"clickCount"];
	[logColumnNames addObject:@"dragCount"];
	[logColumnNames addObject:@"scrollCount"];
	[logColumnNames addObject:@"cursorDistance"];
	int mouseStatsIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"mouseStatsInterval"]] integerValue];
	BOOL doMouseStats = (!(min % mouseStatsIntervalMins));
	if (doMouseStats || doAll) {
        // save for csv output
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",mouseStatsIntervalMins] forKey: @"mouseStatsIntervalMins"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self clickCount]] forKey: @"clickCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self dragCount]] forKey: @"dragCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self scrollCount]] forKey: @"scrollCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self cursorDistance]] forKey: @"cursorDistance"];
        // write to sql
        if (![self.db executeUpdate:@"INSERT INTO mouse (timestamp,datetime,interval,clickCount,dragCount,scrollCount,cursorDistance) VALUES (?, ?, ?, ?, ?, ?, ?)",
            [NSNumber numberWithInt:0],
            nowIsoString,
            [NSNumber numberWithInt:mouseStatsIntervalMins],
            [NSNumber numberWithInt:self.clickCount],
            [NSNumber numberWithInt:self.dragCount],
            [NSNumber numberWithInt:self.scrollCount],
            [NSNumber numberWithInt:self.cursorDistance]
        ]) {
            NSLog(@"mouse stats: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        // reset the counts
        self.clickCount = 0;
        self.dragCount = 0;
        self.scrollCount = 0;
        self.cursorDistance = 0;
    }
    
#pragma mark Log keyboard stats
	[logColumnNames addObject:@"keyboardStatsIntervalMins"];
	[logColumnNames addObject:@"keyCount"];
	[logColumnNames addObject:@"keyDeleteCount"];
	[logColumnNames addObject:@"keyZXCVCount"];
	[logColumnNames addObject:@"wordCount"];
	int keyboardStatsIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"keyboardStatsInterval"]] integerValue];
	BOOL doKeyboardStats = (!(min % keyboardStatsIntervalMins));
	if (doKeyboardStats || doAll) {
		// save for csv output
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",keyboardStatsIntervalMins] forKey: @"keyboardStatsIntervalMins"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self keyCount]] forKey: @"keyCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self keyDeleteCount]] forKey: @"keyDeleteCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self keyZXCVCount]] forKey: @"keyZXCVCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self wordCount]] forKey: @"wordCount"];
        // write to sql
        if (![self.db executeUpdate:@"INSERT INTO keyboard (timestamp,datetime,interval,keyCount,keyDeleteCount,keyZXCVCount,wordCount,keyDeleteRunCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            [NSNumber numberWithInt:0],
            nowIsoString,
            [NSNumber numberWithInt:keyboardStatsIntervalMins],
            [NSNumber numberWithInt:self.keyCount],
            [NSNumber numberWithInt:self.keyDeleteCount],
            [NSNumber numberWithInt:self.keyZXCVCount],
            [NSNumber numberWithInt:self.wordCount],
            [NSNumber numberWithInt:self.keyDeleteRunCount]
         ]) {
            NSLog(@"keyboard stats: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        // reset the counts
        self.keyCount = 0;
        self.keyDeleteCount = 0;
        self.keyZXCVCount = 0;
        self.wordCount = 0;
	}

#pragma mark Log Web stats
	[logColumnNames addObject:@"webStatsIntervalMins"];
	[logColumnNames addObject:@"currentURL"];
	[logColumnNames addObject:@"browserTabCount"];
    
	int webStatsIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"webStatsInterval"]] integerValue];
	BOOL doWebStats = (!(min % webStatsIntervalMins));
	if (doWebStats || doAll) {
        NSString *browserURL = [self getBrowserURL];
        int browserTabCount = [self getBrowserTabCount];
        
		// save for csv output
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",webStatsIntervalMins] forKey: @"webStatsIntervalMins"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%@",browserURL] forKey: @"currentURL"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",browserTabCount] forKey: @"browserTabCount"];
        // write to sql
        if (![self.db executeUpdate:@"INSERT INTO web (timestamp,datetime,interval,currentURL, browserTabCount) VALUES (?, ?, ?, ?, ?)",
              [NSNumber numberWithInt:0],
              nowIsoString,
              [NSNumber numberWithInt:webStatsIntervalMins],
              browserURL,
              [NSNumber numberWithInt:browserTabCount]
              ]) {
            NSLog(@"Web Stats. Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
    }
    
#pragma mark Log Application stats
	[logColumnNames addObject:@"appStatsIntervalMins"];
    [logColumnNames addObject:@"idleSecs"];
	[logColumnNames addObject:@"appSwitchCount"];
	[logColumnNames addObject:@"currentApp"]; // now unused
	[logColumnNames addObject:@"currentURL"]; // now unused
	[logColumnNames addObject:@"serialNumber"];
    
	int appStatsIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"appStatsInterval"]] integerValue];
	BOOL doAppStats = (!(min % appStatsIntervalMins));
	if (doAppStats || doAll) {
        
		// save for csv output
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",appStatsIntervalMins] forKey: @"appStatsIntervalMins"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%lld",SystemIdleTime()]  forKey: @"idleSecs"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",[self appSwitchCount]] forKey: @"appSwitchCount"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%@",[self currentApp]] forKey: @"currentApp"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%@",[self serialNumber]] forKey: @"serialNumber"];
        // write to sql
        if (![self.db executeUpdate:@"INSERT INTO app (timestamp,datetime,interval,idleSecs,appSwitchCount,currentApp,serialNumber) VALUES (?, ?, ?, ?, ?, ?, ?)",
            [NSNumber numberWithInt:0],
            nowIsoString,
            [NSNumber numberWithInt:appStatsIntervalMins],
            [NSNumber numberWithInt:SystemIdleTime()],         
            [NSNumber numberWithInt:self.appSwitchCount],
            [NSString stringWithFormat:@"%@",[self.currentApp bundleIdentifier]],
            [self serialNumber]
             ]) {
            NSLog(@"Application Stats. Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        // reset the counts
        self.appSwitchCount = 0;
    }
    
#pragma mark Log user activity prompt (freeform text)
    // TODO: We should only do this when they are definitively NOT typing or mousing. We don't want to interrupt.
	[logColumnNames addObject:@"promptStatsIntervalMins"];
	[logColumnNames addObject:@"prompt"];
	int promptIntervalMins = [[minuteMapping objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"promptInterval"]] integerValue];
	BOOL doPrompt = (!(min % promptIntervalMins));
	if ((doPrompt || doAll) &&  (promptIntervalMins<100)){
        NSString* userAnswer = [self input:@"What are you doing?" defaultValue:@""];
		// save for csv output
        [logColumnValues setObject: [NSString stringWithFormat:@"%u",promptIntervalMins] forKey: @"promptIntervalMins"];
        [logColumnValues setObject: [NSString stringWithFormat:@"%@",userAnswer] forKey: @"prompt"];
        // write to sql
//        
        if (![self.db executeUpdate:@"INSERT INTO prompt (timestamp,datetime,interval,answer) VALUES (?, ?, ?, ?)",
         [NSNumber numberWithInt:0],
         nowIsoString,
         [NSNumber numberWithInt:promptIntervalMins],
         userAnswer
         ]) {
            NSLog(@"User prompt: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        }; 
    }
    
    //
	// Write our results to log file
    //
    NSString *logFilename = [NSString stringWithFormat:@"%@/lifeslice.csv", self.appDirectory];
	FILE * pFile;
	pFile = fopen ([logFilename UTF8String] ,"a");
	if (!pFile) {
		fprintf(stderr,"Could not open log file.\n");
		return 0;
	}
    // if file is empty, first write column names
    if ([[[NSFileManager defaultManager] attributesOfItemAtPath:logFilename error:nil] fileSize] == 0) {
        for (id logColumn in logColumnNames) {
          	fprintf (pFile, "%s, ", [logColumn UTF8String]);
        }
        fprintf (pFile, "\n");
    }
    // if there is no data to log, don't write anything
    BOOL isDataToLog = NO;
	for (id logColumn in logColumnNames) {
		if ([logColumnValues objectForKey: logColumn]) {
            isDataToLog = YES;
            break;
        }
    }
    // write our data to file
    if (isDataToLog) {
        for (id logColumn in logColumnNames) {
            if ([logColumnValues objectForKey: logColumn]) {
                fprintf (pFile, "%s, ", [[logColumnValues objectForKey: logColumn] UTF8String]);
            }
            else {
                // no value, print empty
                fprintf (pFile, ", ");
            }
        }
        fprintf(pFile, "\n");
    }
	fclose(pFile);
	   
    [self.db close];
    
    // Write little log file to indicate that this process is alive. 
    [nowIsoString writeToFile:[self.appDirectory stringByAppendingPathComponent:@".APPLICATION_RUNNING_FLAG.txt"]
          atomically:NO
            encoding:NSStringEncodingConversionAllowLossy
               error:nil];
    
	return 1;
}

#pragma mark -
#pragma mark Capture mouse and keyboard events
#pragma mark -

- (void)handleEvent:(NSEvent *)incomingEvent {

	if ([incomingEvent type] == NSMouseMoved) {
        float ptxd = [NSEvent mouseLocation].x - self.lastCursorPoint.x;
        float ptyd = [NSEvent mouseLocation].y - self.lastCursorPoint.y;
        self.lastCursorPoint = [NSEvent mouseLocation];
        self.cursorDistance+= (int)sqrtf( ptxd*ptxd + ptyd*ptyd );
        self.dayCursorDistance+= (int)sqrtf( ptxd*ptxd + ptyd*ptyd );
	}
    
	if ([self lastEventType] == NSScrollWheel) {
		self.currentScrollEventCount++;
        self.dayCurrentScrollEventCount++;
	}
	if (([self lastEventType] == NSScrollWheel) && ([incomingEvent type] != NSScrollWheel)) {
		// end of drag
		if (self.currentScrollEventCount>MIN_SCROLLEVENTS_FOR_SCROLL) {
			self.scrollCount++;
            self.dayScrollCount++;
			self.currentScrollEventCount = 0;
		}
		else {
			self.currentScrollEventCount = 0;
		}
	}
	if (([self lastEventType] == NSLeftMouseDragged) && ([incomingEvent type] != NSLeftMouseDragged)) {
		// end of drag
		self.dragCount++;
        self.dayDragCount++;
	}
	else if ([incomingEvent type] == NSLeftMouseUp) {
		self.clickCount++;
        self.dayClickCount++;
	}

	if ([incomingEvent type] == NSKeyDown) {
        
        // Constants for weird keys declared here: https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/Classes/NSEvent_Class/Reference/Reference.html#//apple_ref/occ/instm/NSEvent/modifierFlags
        //        NSLog(@"NSCommandKeyMask %u",NSCommandKeyMask);
        //		NSLog(@"Got a keyboard event. %u '%@' '%@' %lu",
        //			  [incomingEvent keyCode],
        //			  [incomingEvent characters],
        //			  [incomingEvent charactersIgnoringModifiers],
        //			  (unsigned long)[incomingEvent modifierFlags]
        //        );
        
        if (([incomingEvent modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask) {
            // command key was pressed
            self.keyZXCVCount++;
            self.dayKeyZXCVCount++;
        }
        else if ([incomingEvent keyCode] == 51) {
            // delete/backspace
            // note that this does NOT break a run of word-letters
            self.keyDeleteCount++;
            self.dayKeyDeleteCount++;
            
            // Count runs of deletes separately
            if (self.lastKeyCode != 51) {
                self.keyDeleteRunCount++;
                self.dayKeyDeleteRunCount++;
            }
        }
        else if ([[[incomingEvent characters] stringByTrimmingCharactersInSet:[NSCharacterSet alphanumericCharacterSet]] isEqualToString:@""]) {
            // TODO: an apostrophe should be counted as part of the word
            // it was a letter (or number), so we increment our count of word-letters
            self.wordKeyCount++;            
        }
        else {
            // non-alphanumeric key, so this would end any word that we had going.
            if (self.wordKeyCount >= 1) {
                self.wordCount++;
                self.dayWordCount++;
            }
            self.wordKeyCount = 0;
        }
        self.lastKeyCode = [incomingEvent keyCode];
		self.keyCount++;
        self.dayKeyCount++;
	}
    else {
        // If event wasn't a keydown, then we've done something else and our word is over.
        // Is this really true?
        self.wordKeyCount = 0;
    }
    
    //	else if ([self lastEventType] != [incomingEvent type]) {
    //		//NSLog(@"I like change! %u %u",[self lastEventType],[incomingEvent type]);
    //	}
	
	self.lastEventType = [incomingEvent type];
}

#pragma mark -
#pragma mark Location Manager
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation start");

#ifdef RELEASE_TEST_BUILD
    // Don't report lat/lon on production builds, as this could end up in submitted error log.
    NSLog(@"Got lat/lon location. ");
#else
	NSLog(@"Got lat/lon location. We're at %f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
#endif
    
	self.lat = newLocation.coordinate.latitude;
	self.lon = newLocation.coordinate.longitude;
	
//	// Ignore updates where nothing we care about changed
//	if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
//		newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
//		newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
//	{
//		return;
//	}
    
    NSLog(@"didUpdateToLocation done, so closing down locationmanager");
    [locationManager stopUpdatingLocation];
    
    // TODO: reverse geo-coding of location
    // http://wiki.openstreetmap.org/wiki/Nominatim#Reverse%5FGeocoding%5F.2F%5FAddress%5Flookup
    
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError. Error: %@", error);
}

#pragma mark -
#pragma mark Reporting Window
#pragma mark -


- (void)generateAggregateReports {
    
    // Set up SQLite
    FMDatabase *reportingDB;
    NSLog(@"Connecting to Sqlite database - reportingDB");
    reportingDB = [FMDatabase databaseWithPath:[self.appDirectory stringByAppendingPathComponent:@"lifeslice.sqlite"]];
    if (![reportingDB open]) {
        NSLog(@"ERROR: Could not open db.");
        return;
    }
    
    
    // Calculate aggregate statistics
    [reportingDB executeUpdate:@"DROP TABLE IF EXISTS `dailyAggregates_generated`;"];
    NSString *dailyAggregateSQL = 	@""
    "CREATE TABLE `dailyAggregates_generated` AS "
	"SELECT "
	"	SUBSTR(app.datetime,0,11) AS date "
	"	,SUM(app.interval) AS dailyMinutesOn"
	"	,SUM(app.appSwitchCount) AS dailyAppSwitchCount "
	"	,SUM(keyboard.keyCount) AS dailyKeyCount "
	"	,SUM(keyboard.keyZXCVCount) AS dailyKeyDeleteCount "
	"	,((SUM(keyboard.keyDeleteCount)+1.0) / SUM(keyboard.wordCount)) AS dailyDeletesPerWord "
	"	,SUM(keyboard.keyZXCVCount) AS dailyKeyZXCVCount "
	"	,SUM(keyboard.wordCount) AS dailyWordCount "
	"	,((SUM(keyboard.wordCount)+1.0) / SUM(app.interval)) AS dailyWordsPerMinute "
	"	,SUM(keyboard.keyDeleteRunCount) AS dailyKeyDeleteRunCount "
	"	,SUM(mouse.clickCount) AS dailyClickCount "
	"	,SUM(mouse.dragCount) AS dailyDragCount "
	"	,SUM(mouse.scrollCount) AS dailyScrollCount "
	"	,SUM(mouse.cursorDistance) AS dailyCursorDistance "
	"FROM app "
	"LEFT JOIN keyboard ON app.datetime = keyboard.datetime "
	"LEFT JOIN mouse ON app.datetime = mouse.datetime "
	"GROUP BY date "
	"ORDER BY date;"
    ;
    if (![reportingDB executeUpdate:dailyAggregateSQL]) {
        NSLog(@"ERROR: dailyAggregateSQL: Database Error %d: %@", [reportingDB lastErrorCode], [reportingDB lastErrorMessage]);
    };
    
    // Calculate daily maximums
    [reportingDB executeUpdate:@"DROP TABLE IF EXISTS `dailyMaxAggregates_generated`;"];
    NSString *dailyMaxAggregatesSQL = @""
    "CREATE TABLE `dailyMaxAggregates_generated` AS "
    "SELECT 'dailyMinutesOn' AS field,MAX(dailyMinutesOn) AS max,date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyAppSwitchCount',MAX(dailyAppSwitchCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyKeyCount',MAX(dailyKeyCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyKeyDeleteCount',MAX(dailyKeyDeleteCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyDeletesPerWord',MAX(dailyDeletesPerWord),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyKeyZXCVCount',MAX(dailyKeyZXCVCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyWordCount',MAX(dailyWordCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyWordsPerMinute',MAX(dailyWordsPerMinute),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyKeyDeleteRunCount',MAX(dailyKeyDeleteRunCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyClickCount',MAX(dailyClickCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyDragCount',MAX(dailyDragCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyScrollCount',MAX(dailyScrollCount),date FROM dailyAggregates "
    "UNION "
    "SELECT 'dailyCursorDistance',MAX(dailyCursorDistance),date FROM dailyAggregates "
    ;
    if (![reportingDB executeUpdate:dailyMaxAggregatesSQL]) {
        NSLog(@"ERROR: dailyMaxAggregatesSQL: Database Error %d: %@", [reportingDB lastErrorCode], [reportingDB lastErrorMessage]);
    };
    
    [reportingDB close];
}

- (void) exportReportData
{
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:self.appDirectory];
    
    // Run our generated reports
    system([[NSString stringWithFormat:@"sqlite3 lifeslice.sqlite < '%@'",[[NSBundle mainBundle] pathForResource:@"reports" ofType:@"sql"]] UTF8String]);
    
    // Dump our sqlite data to a csv (for d3 to use)
    system("echo '.mode csv\n.headers on\nselect * from webcam;'     | sqlite3 lifeslice.sqlite > html/webcam.csv    ");
    system("echo '.mode csv\n.headers on\nselect * from screenshot;' | sqlite3 lifeslice.sqlite > html/screenshot.csv");
    system("echo '.mode csv\n.headers on\nselect * from keyboard;'   | sqlite3 lifeslice.sqlite > html/keyboard.csv  ");
    system("echo '.mode csv\n.headers on\nselect * from app;'        | sqlite3 lifeslice.sqlite > html/app.csv       ");
    system("echo '.mode csv\n.headers on\nselect * from mouse;'      | sqlite3 lifeslice.sqlite > html/mouse.csv     ");
    system("echo '.mode csv\n.headers on\nselect * from location;'   | sqlite3 lifeslice.sqlite > html/location.csv  ");
    
    system("echo '.mode csv\n.headers on\nselect * from _generated_dailyAggregates;'     | sqlite3 lifeslice.sqlite > html/dailyAggregates.csv  ");
    system("echo '.mode csv\n.headers on\nselect * from _generated_dailyMaxAggregates;'  | sqlite3 lifeslice.sqlite > html/dailyMaxAggregates.csv  ");
    system("echo '.mode csv\n.headers on\nselect * from _generated_hourlyAggregates;'    | sqlite3 lifeslice.sqlite > html/dailyMaxAggregates.csv  ");
    system("echo '.mode csv\n.headers on\nselect * from _generated_hourlyMaxAggregates;' | sqlite3 lifeslice.sqlite > html/dailyMaxAggregates.csv  ");
}

- (void) showBrowseSliceWindowForDate:(NSString*)isoDate
{
    NSLog(@"Preparing BrowseLife window");

    [self exportReportData];
    
    // Give time for our report files to write. 0.75 seconds // TODO: Make this smarter. This is a hack.
    [NSThread sleepForTimeInterval:0.75];

    NSString *sliceBrowserHtmlFilename = sliceBrowserHtmlFilename = [NSString stringWithFormat:@"%@/html/slicebrowser-day-d3.html?date=%@&rand=%d", self.appDirectory, (isoDate ? isoDate : @"") , (arc4random() % 65536)];
    
    // Load webpage from file
    // file:///Users/stan/Lifeslice/reports/lifeslice-report-2012-06.html
    //NSURL* fileURL = [NSURL fileURLWithPath:@"file:///Users/stan/Lifeslice/reports/lifeslice-report-2012-06.html"];
    //    NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
    //    [[theWebView mainFrame] loadRequest:request];
    
    NSLog(@"Showing BrowseSliceWindow window!");
    [browseSliceWindow makeKeyAndOrderFront:self];
    [browseSliceWindow setDelegate:self];
    [(NSWindow*)browseSliceWindow center];
    [NSApp activateIgnoringOtherApps:YES];
    
    //    [theWebView setMainFrameURL:@"file:///Users/stan/Lifeslice/reports/lifeslice-report-2012-06.html"];
    [theWebView setMainFrameURL:[@"file://" stringByAppendingPathComponent:sliceBrowserHtmlFilename]];

}

/**
 * Our browser window for exploring our logged data
 *
 * Use this: http://blog.grio.com/2012/07/uiwebview-javascript-to-objective-c-communication.html
 */
- (IBAction)showBrowseSliceWindow:(id)pId {
    [self showBrowseSliceWindowForDate:nil];
}

//
///**
// * Receive "messages" 
// */
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    NSArray *requestArray = [requestString componentsSeparatedByString:@":##sendToApp##"];
//    
//    if ([requestArray count] > 1){
//        NSString *requestPrefix = [[requestArray objectAtIndex:0] lowercaseString];
//        NSString *requestMssg = ([requestArray count] > 0) ? [requestArray objectAtIndex:1] : @"";
//        [self webviewMessageKey:requestPrefix value:requestMssg];
//        return NO;
//    }
//    else if (navigationType == UIWebViewNavigationTypeLinkClicked && [self shouldOpenLinksExternally]) {
//        [[UIApplication sharedApplication] openURL:[request URL]];
//        return NO;
//    }
//    return YES;
//}
//- (void)webviewMessageKey:(NSString *)key value:(NSString *)val {}
//- (BOOL)shouldOpenLinksExternally {
//    return YES;
//}
//
#pragma mark -
#pragma mark Open windows (and force to front)
#pragma mark -

- (IBAction)showPreferencesWindow:(id)pId {
    NSLog(@"Showing preferences window!");
    
    // Set the "launch at startup" checkbox to reflect current state
    // (May have changed while program running)
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [myLaunchAtStartupCheckbox setState:([launchController launchAtLogin] ? NSOnState : NSOffState )];
    
    [preferencesWindow makeKeyAndOrderFront:pId];
    [(NSWindow*)preferencesWindow center];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showLiveStatsWindow:(id)pId {
    NSLog(@"Showing live stats window!");
    [liveStatsWindow setBackgroundColor: NSColor.whiteColor];
    [liveStatsWindow makeKeyAndOrderFront:pId];
    [liveStatsWindow setLevel:NSFloatingWindowLevel]; // keep it on top
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showAboutWindow:(id)pId {
    
    NSLog(@"Showing about window!");

    [versionLabel setStringValue: [NSString stringWithFormat:@"Version %@ (%@)",
                                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]
    ];
    
    [aboutWindow setBackgroundColor: NSColor.whiteColor];
    [aboutWindow makeKeyAndOrderFront:pId];
    [aboutWindow setLevel:NSFloatingWindowLevel]; // keep it on top
    [NSApp activateIgnoringOtherApps:YES];

#ifdef RELEASE_TEST_BUILD

#else

    
    // Testing area
//    [self showYesterdaySummaryNotification];

#endif
    
}

- (IBAction)showLocationInMaps:(id)pId {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps?q=%f+%f&t=m&z=16",self.lat,self.lon]]];
}

/**
 * Delete the last slice that we recorded
 */
- (IBAction)deleteLatestSlice:(id)pId {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete the last slice?"];
    [alert setInformativeText: [NSString stringWithFormat:@"This will delete all images and data for the last slice, %@. Are you sure?", lastSliceIsoDate]];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        
        // ISO datetime
        NSDateFormatter *f3 = [[NSDateFormatter alloc] init];
        [f3 setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':00Z'Z"];
        NSString *datetimeIsoString = [f3 stringFromDate:self->lastSliceDate];
        // Filename datetime
        NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
        [f2 setDateFormat:@"yyyy'-'MM'-'dd'T'HH'-'mm'-00Z'Z"];
        NSString *datetimeFileString = [f2 stringFromDate:self->lastSliceDate];
        
        // Set up SQLite
        NSLog(@"Connecting to Sqlite database");
        self.db = [FMDatabase databaseWithPath:[self.appDirectory stringByAppendingPathComponent:@"lifeslice.sqlite"]];
        if (![self.db open]) {
            NSLog(@"ERROR: Could not open db.");
            return;
        }

        // Delete database records
        if (![self.db executeUpdate:@"DELETE FROM webcam WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        if (![self.db executeUpdate:@"DELETE FROM screenshot WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        if (![self.db executeUpdate:@"DELETE FROM location WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        if (![self.db executeUpdate:@"DELETE FROM mouse WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        if (![self.db executeUpdate:@"DELETE FROM keyboard WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        if (![self.db executeUpdate:@"DELETE FROM app WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        if (![self.db executeUpdate:@"DELETE FROM prompt WHERE datetime=?" ,datetimeIsoString]) {
            NSLog(@"ERROR: webcam: Database Error %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
        };
        
        // Delete screenshots and/or webcam shots (including thumbnails)
        NSString *webcamShotFilename = [NSString stringWithFormat:@"face_%@.jpg", datetimeFileString];
        NSString *webcamShotPathname = [[self.appDirectory stringByAppendingPathComponent:@"webcam"] stringByAppendingPathComponent:webcamShotFilename];
        [[NSFileManager defaultManager] removeItemAtPath:webcamShotPathname error:nil];
        
        NSString *screenShotFilename = [NSString stringWithFormat:@"screen_%@.png", datetimeFileString];
        NSString *screenShotPathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot"] stringByAppendingPathComponent:screenShotFilename];
        [[NSFileManager defaultManager] removeItemAtPath:screenShotPathname error:nil];
        
        NSString *screenShot2Filename = [NSString stringWithFormat:@"screen_2_%@.png", datetimeFileString]; // for 2nd monitor
        NSString *screenShot2Pathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot"] stringByAppendingPathComponent:screenShot2Filename];
        [[NSFileManager defaultManager] removeItemAtPath:screenShot2Pathname error:nil];
        
        NSString *webcamShotThumbFilename = [NSString stringWithFormat:@"face_%@.jpg", datetimeFileString];
        NSString *webcamShotThumbPathname = [[self.appDirectory stringByAppendingPathComponent:@"webcam_thumbs"] stringByAppendingPathComponent:webcamShotThumbFilename];
        [[NSFileManager defaultManager] removeItemAtPath:webcamShotThumbPathname error:nil];
        
        NSString *screenShotThumbFilename = [NSString stringWithFormat:@"screen_%@.png", datetimeFileString];
        NSString *screenShotThumbPathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot_thumbs"] stringByAppendingPathComponent:screenShotThumbFilename];
        [[NSFileManager defaultManager] removeItemAtPath:screenShotThumbPathname error:nil];
        
        NSString *screenShot2ThumbFilename = [NSString stringWithFormat:@"screen_2_%@.png", datetimeFileString];
        NSString *screenShot2ThumbPathname = [[self.appDirectory stringByAppendingPathComponent:@"screenshot_thumbs"] stringByAppendingPathComponent:screenShot2ThumbFilename];
        [[NSFileManager defaultManager] removeItemAtPath:screenShot2ThumbPathname error:nil];
        
        // remove preview images from live stats
        [screenshotPreview setImage:nil];
        [webcamPreview setImage:nil];
        
        [self.db close];
    }
}

/**
 * Show window for users to give feedback
 */
- (IBAction)showFeedbackWindow:(id)pId {
    NSLog(@"Loading feedbak webpage.");
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://wanderingstan.com/lifeslice-feedback"]];
}

/**
 * Show our homepage
 */
- (IBAction)showHomepage:(id)pId {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://wanderingstan.github.io/Lifeslice/"]];
    [aboutWindow close];
}

#pragma mark -
#pragma mark Notification Center
#pragma mark -

- (void) showYesterdaySummaryNotification
{

    // Get total values for yesterday
    NSDate* yesterday = [[NSDate date] dateByAddingTimeInterval:(24*60*60*-1)];

    NSDateFormatter *f1 = [[NSDateFormatter alloc] init];
    [f1 setDateStyle:kCFDateFormatterFullStyle];
    NSString *yesterdayPrettyDateString = [f1 stringFromDate:yesterday]; // E.g. "Thursday, December 25, 2014" (In USA)

    NSString* reportText;
    {
        FMDatabase *yesterdayDb = [FMDatabase databaseWithPath:[self.appDirectory stringByAppendingPathComponent:@"lifeslice.sqlite"]];
        if (![yesterdayDb open]) {
            NSLog(@"Could not open db.");
            return;
            // TODO: Find OSX error reporting, a la crashlytics
        }
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy'-'MM'-'dd'%'"];
        NSString *yesterdayDateIsoString = [f stringFromDate:yesterday];

        int yesterdayKeyCount = 0;
        int yesterdayKeyDeleteCount = 0;
        int yesterdayKeyZXCVCount = 0;
        int yesterdayWordCount = 0;
        int yesterdayAppSwitchCount = 0;
        int yesterdayMinuteCount = 0;
        int yesterdayClickCount = 0;
        int yesterdayDragCount = 0;
        int yesterdayScrollCount = 0;
        int yesterdayCursorDistance = 0;

        FMResultSet *rs1 = [yesterdayDb executeQuery:[NSString stringWithFormat:@"SELECT SUM(keyCount) AS dayKeyCount, SUM(keyDeleteCount) AS dayKeyDeleteCount, SUM(keyZXCVCount) AS dayKeyZXCVCount, SUM(wordCount) AS dayWordCount FROM keyboard WHERE datetime LIKE '%@';", yesterdayDateIsoString]];
        while ([rs1 next]) {
            yesterdayKeyCount = [rs1 intForColumn:@"dayKeyCount"];
            yesterdayKeyDeleteCount = [rs1 intForColumn:@"dayKeyDeleteCount"];
            yesterdayKeyZXCVCount = [rs1 intForColumn:@"dayKeyZXCVCount"];
            yesterdayWordCount = [rs1 intForColumn:@"dayWordCount"];
        }
        FMResultSet *rs2 = [yesterdayDb executeQuery:[NSString stringWithFormat:@"SELECT SUM(interval) AS dayMinuteCount, SUM(appSwitchCount) AS dayAppSwitchCount FROM app WHERE datetime LIKE '%@';", yesterdayDateIsoString]];
        while ([rs2 next]) {
            yesterdayAppSwitchCount = [rs2 intForColumn:@"dayAppSwitchCount"];
            yesterdayMinuteCount = [rs2 intForColumn:@"dayMinuteCount"];
        }
        FMResultSet *rs3 = [yesterdayDb executeQuery:[NSString stringWithFormat:@"SELECT SUM(clickCount) AS dayClickCount,SUM(dragCount) AS dayDragCount,SUM(scrollCount) AS dayScrollCount, SUM(cursorDistance) AS dayCursorDistance FROM mouse WHERE datetime LIKE '%@';", yesterdayDateIsoString]];
        while ([rs3 next]) {
            yesterdayClickCount = [rs3 intForColumn:@"dayClickCount"];
            yesterdayDragCount = [rs3 intForColumn:@"dayDragCount"];
            yesterdayScrollCount = [rs3 intForColumn:@"dayScrollCount"];
            yesterdayCursorDistance = [rs3 intForColumn:@"dayCursorDistance"];
        }
        
        [rs1 close];
        [rs2 close];
        [rs3 close];
        [yesterdayDb close];
        
        // TODO: Report hours that user was working (productive vs passive?)
        reportText = [NSString stringWithFormat:@"Hours: %.2f Words:%d Keys:%d Clicks:%d Distance:%d", yesterdayMinuteCount / 60.0,  yesterdayWordCount, yesterdayKeyCount, yesterdayClickCount, yesterdayCursorDistance];
    }
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"LifeSlice Report";
    notification.subtitle = [NSString stringWithFormat:@"Yesterday, %@", yesterdayPrettyDateString];
    notification.informativeText = reportText;
    notification.soundName = nil;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    if (notification.activationType != NSUserNotificationActivationTypeNone) {
        // TODO: Figure out a way to set window to yesterday
        NSDate* yesterday = [[NSDate date] dateByAddingTimeInterval:(24*60*60*-1)];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy'-'MM'-'dd"];
        NSString *yesterdayDateIsoString = [f stringFromDate:yesterday];

        [self showBrowseSliceWindowForDate:yesterdayDateIsoString];
    }
}

#pragma mark -
#pragma mark Misc/Helper functions
#pragma mark -


/**
 * Interface to import old data
 */
- (IBAction)importOldLifeSlice:(id)pId {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Import old LifeSlice Data?"];
    [alert setInformativeText:@"This may take a few minutes.\n\nA terminal window will appear with lots of file names and scary-looking computer text. Wait until you see a 'Finished!' message before closing that window."];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        // OK clicked, do the import
        [self importOldLifeSliceRun];
    }
}

/**
 * Import old-style LifeSlice data (tons of text files and images
 */
- (void)importOldLifeSliceRun {
    NSLog(@"Importing old lifeslice data");
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"old_import" ofType:@"py"]]) {
        [self reportErrorAndUploadLog:[NSString stringWithFormat:@"A necessary file for importing could not be found: %@",[[NSBundle mainBundle] pathForResource:@"old_import" ofType:@"py"]]];
    }
    else {
        // Run it in a visible terminal window. Ugly, but better than nothing.
        NSString *s = [NSString stringWithFormat:
                       @"tell application \"Terminal\" to do script \"python %@\"", [[NSBundle mainBundle] pathForResource:@"old_import" ofType:@"py"]];
        NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
        [as executeAndReturnError:nil];
    }
}

/**
 * Open the finder at a specific location
 */
- (IBAction)revealFilesInFinder:(id)pId;
{
    NSURL* url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"file://%@", self.appDirectory] isDirectory:NO];
	NSLog(@"Showing files at %@",url);
    NSArray *fileURLs = [NSArray arrayWithObjects:url, nil];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

/**
 * Get serial number of the mac
 * http://stackoverflow.com/questions/5868567/unique-identifier-of-a-mac
 */
- (NSString *)serialNumber
{
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;
    
    if (platformExpert) {
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                 CFSTR(kIOPlatformSerialNumberKey),
                                                                 kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }
    
    NSString *serialNumberAsNSString = nil;
    if (serialNumberAsCFString) {
        serialNumberAsNSString = [NSString stringWithString:(__bridge NSString *)serialNumberAsCFString];
        CFRelease(serialNumberAsCFString);
    }
    
    return serialNumberAsNSString;
}

/**
 * Get count of how many browser tabs are open (only Safari right now)
 */
- (NSInteger *)getBrowserTabCount {
    if ([[NSString stringWithFormat:@"%@",self.currentApp] rangeOfString:@"com.apple.Safari"].location != NSNotFound) {
        // get current tab count of safari
        NSAppleScript *script= [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" to return number of tabs of front window as string"];
        NSDictionary *scriptError = nil;
        NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&scriptError];
        if(scriptError) {
            NSLog(@"Error: %@",scriptError);
            return 0;
        }
        else {
            NSAppleEventDescriptor *unicode = [descriptor coerceToDescriptorType:typeUnicodeText];
            NSData *data = [unicode data];
            NSString *result = [[NSString alloc] initWithCharacters:(unichar*)[data bytes] length:[data length] / sizeof(unichar)];
            return [result integerValue];
        }
    }
    else if ([[NSString stringWithFormat:@"%@",self.currentApp] rangeOfString:@"com.google.Chrome"].location != NSNotFound) {
        // get current tab count of chrome
        NSAppleScript *script= [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\"\n  return (count of tabs of first window) as string\n end tell"];
        NSDictionary *scriptError = nil;
        NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&scriptError];
        if(scriptError) {
            NSLog(@"Error: %@",scriptError);
            return 0;
        }
        else {
            NSAppleEventDescriptor *unicode = [descriptor coerceToDescriptorType:typeUnicodeText];
            NSData *data = [unicode data];
            NSString *result = [[NSString alloc] initWithCharacters:(unichar*)[data bytes] length:[data length] / sizeof(unichar)];
            return [result integerValue];
        }
    }
    else {
        return 0;
    }
}

/**
 * Return current URL on browser
 */
- (NSString *)getBrowserURL  {
    if ([[NSString stringWithFormat:@"%@",self.currentApp] rangeOfString:@"com.apple.Safari"].location != NSNotFound) {
        // get current URL of safari
        
        // http://stackoverflow.com/questions/6111275/how-to-copy-the-current-active-browser-url
        NSAppleScript *script= [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" to return URL of front document as string"];
        NSDictionary *scriptError = nil;
        NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&scriptError];
        if(scriptError) {
            NSLog(@"Error: %@",scriptError);
            return [NSString stringWithFormat:@"Safari Error: %@",scriptError];
        }
        else {
            NSAppleEventDescriptor *unicode = [descriptor coerceToDescriptorType:typeUnicodeText];
            NSData *data = [unicode data];
            NSString *result = [[NSString alloc] initWithCharacters:(unichar*)[data bytes] length:[data length] / sizeof(unichar)];
            return result;
        }
    }
    else if ([[NSString stringWithFormat:@"%@",self.currentApp] rangeOfString:@"com.google.Chrome"].location != NSNotFound) {
        // get current URL of chrome
        // http://stackoverflow.com/questions/6111275/how-to-copy-the-current-active-browser-url
        // http://stackoverflow.com/questions/2483033/get-the-url-of-the-frontmost-tab-from-chrome-on-os-x
        NSAppleScript *script= [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\"\n  get URL of active tab of window 1\nend tell"];
        NSDictionary *scriptError = nil;
        NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&scriptError];
        if(scriptError) {
            NSLog(@"Error: %@",scriptError);
            return [NSString stringWithFormat:@"Chrome Error: %@",scriptError];
        }
        else {
            NSAppleEventDescriptor *unicode = [descriptor coerceToDescriptorType:typeUnicodeText];
            NSData *data = [unicode data];
            NSString *result = [[NSString alloc] initWithCharacters:(unichar*)[data bytes] length:[data length] / sizeof(unichar)];
            return result;
        }
    }
    else {
        // TODO: Firefox
        // Possibility: http://stackoverflow.com/a/5300277/59913
        return @"";
    }
}

/**
 * Prompt user and return their input
 */
- (NSString *)input:(NSString *)prompt defaultValue:(NSString *)defaultValue {
    // bring our app to front
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %d", (int)button);
        return nil;
    }
}

/**
 Returns the number of seconds the machine has been idle or -1 if an error occurs.
 The code is compatible with Tiger/10.4 and later (but not iOS).
 */
int64_t SystemIdleTime(void) {
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry) {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds >> 30); // Divide by 10^9 to convert from nanoseconds to seconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    return idlesecs;
}
@end
