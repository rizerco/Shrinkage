//
//  AppDelegate.m
//  Shrinkage
//
//  Created by Luke Rogers on 11/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import "AppDelegate.h"
#import "SCEvent.h"
#import "SCEvents.h"
#import "ResizeController.h"
#import "MASPreferencesWindowController.h"
#import "AdvancedPreferencesViewController.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize resizeController;
@synthesize statusItem;
@synthesize statusBarMenu;
@synthesize preferencesWindowController = _preferencesWindowController;
@synthesize fileSystemEvents;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self activateStatusMenu];
	
	[self setResizeController:[[ResizeController alloc] initInManagedObjectContext:[self managedObjectContext]]];
	
	[self setFileSystemEvents:[[SCEvents alloc] init]];
	[[self fileSystemEvents] setDelegate:self];
	
	[self beginObservationThread:nil];
	
	if([[NSUserDefaults standardUserDefaults] valueForKey:@"IncludedDirectories"] == nil)
	{
		[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"IncludedDirectories"];
	}
	if([[NSUserDefaults standardUserDefaults] valueForKey:@"ExcludedDirectories"] == nil)
	{
		[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"ExcludedDirectories"];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginObservationThread:) name:@"ObserveredDirectoriesChanged" object:nil];
	
}

- (void)beginObservationThread:(NSNotification*)notification;
{
	if(notification)
	{
		NSLog(@"begin observing %@",[notification object]);
		NSLog(@"user defaults %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"IncludedDirectories"]);
	}
	NSThread *observingThread = [[NSThread alloc] initWithTarget:self selector:@selector(startObservingFileSystem) object:nil];
	[observingThread start];
}

- (void)startObservingFileSystem
{
	NSMutableArray *paths = [[NSUserDefaults standardUserDefaults] valueForKey:@"IncludedDirectories"];
	if([[self fileSystemEvents] isWatchingPaths])
	{
		[[self fileSystemEvents] stopWatchingPaths];
	}
	[fileSystemEvents setExcludedPaths:[[NSUserDefaults standardUserDefaults] valueForKey:@"ExcludedDirectories"]];
	[[self fileSystemEvents] startWatchingPaths:paths];
	NSLog(@"events %@",[[self fileSystemEvents] streamDescription]);
	[[NSRunLoop currentRunLoop] run];
}

#pragma mark - Status Bar
- (void)activateStatusMenu
{
    [self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:24]];
	[self setStatusBarMenu:[[NSMenu alloc] init]];
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Shrinkage is active" action:nil keyEquivalent:@""];
	[[self statusBarMenu] addItem:item];
	
	[[self statusBarMenu] addItem:[NSMenuItem separatorItem]];
	
	// Preferences
	NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences…" action:@selector(openPreferences:) keyEquivalent:@""];
	[[self statusBarMenu] addItem:preferencesMenuItem];
	
	[[self statusBarMenu] addItem:[NSMenuItem separatorItem]];
	
	// Quit
	NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Shrinkage" action:@selector(quitApplication:) keyEquivalent:@""];
	[[self statusBarMenu] addItem:quitMenuItem];

    [[self statusItem] setHighlightMode:YES];
	[[self statusItem] setImage:[NSImage imageNamed:@"statusBarIcon.png"]];
	[[self statusItem] setAlternateImage:[NSImage imageNamed:@"alternateStatusBarIcon.png"]];
	[[self statusItem] setMenu:[self statusBarMenu]];
}

#pragma mark - Actions

- (void)openPreferences:(id)sender
{
    [[self preferencesWindowController] showWindow:nil];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)quitApplication:(id)sender
{
	[[NSApplication sharedApplication] terminate:sender];
}

#pragma mark - Accessors
- (MASPreferencesWindowController*)preferencesWindowController
{
	// Lazy loading
	if (_preferencesWindowController == nil)
    {
        GeneralPreferencesViewController *generalViewController = [[GeneralPreferencesViewController alloc] init];
		[generalViewController setDelegate:self];
        NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, nil];
        
        NSString *title = NSLocalizedString(@"Preferences", @"Preferences");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}

#pragma mark - SCEventListenerProtocol methods
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
	// Something somewhere happened, so check for changes at that path
	[[self resizeController] processDirectory:[event eventPath]];
}

#pragma mark - GeneralPreferencesDelegate methods
- (void)shouldRescanDirectory:(NSString*)directoryPath
{
	NSArray *subpaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directoryPath error:nil];
	
	NSArray *excludedDirectories = [[NSUserDefaults standardUserDefaults] valueForKey:@"ExcludedDirectories"];
	for(NSString *subpath in subpaths)
	{
		NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:subpath];
		BOOL isDirectory;
		if([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath isDirectory:&isDirectory])
		{
			if(isDirectory)
			{
				// Make sure directory isn't excluded – important to make sure that file paths
				// are always stored the same way
				if(![excludedDirectories containsObject:fullFilePath])
				{
					[[self resizeController] processDirectory:fullFilePath];
				}
			}
		}
	}
}

#pragma mark - Core Data
/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Shrinkage" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Shrinkage"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Shrinkage" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator)
	{
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Shrinkage.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = coordinator;

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
