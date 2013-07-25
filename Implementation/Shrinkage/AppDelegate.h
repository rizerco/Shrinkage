//
//  AppDelegate.h
//  Shrinkage
//
//  Created by Luke Rogers on 11/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"
#import "GeneralPreferencesViewController.h"

@class ResizeController;
@class MASPreferencesWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate,SCEventListenerProtocol,GeneralPreferencesDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) ResizeController *resizeController;
@property (nonatomic,strong) NSStatusItem *statusItem;
@property (nonatomic,strong) NSMenu *statusBarMenu;
@property (nonatomic,strong) MASPreferencesWindowController *preferencesWindowController;
@property (nonatomic,strong) SCEvents *fileSystemEvents;

- (void)beginObservationThread:(NSNotification*)notification;
- (void)startObservingFileSystem;
- (void)activateStatusMenu;
- (void)openPreferences:(id)sender;
- (void)quitApplication:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
