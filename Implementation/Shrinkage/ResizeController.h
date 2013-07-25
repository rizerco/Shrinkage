//
//  ResizeController.h
//  Shrinkage
//
//  Created by Luke Rogers on 11/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ImageFile;

@interface ResizeController : NSObject

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

- (id)initInManagedObjectContext:(NSManagedObjectContext*)context;
- (void)processDirectory:(NSString*)directoryPath;
- (ImageFile*)storeReferenceToFileAtPath:(NSString*)filePath modificationDate:(NSDate*)modifcationDate;
- (ImageFile*)imageFileForFilePath:(NSString*)filePath;

@end
