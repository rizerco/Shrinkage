//
//  ResizeController.m
//  Shrinkage
//
//  Created by Luke Rogers on 11/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import "ResizeController.h"
#import "ImageFile.h"

@implementation ResizeController

@synthesize managedObjectContext;

- (id)initInManagedObjectContext:(NSManagedObjectContext*)context
{
	if((self = [super init]))
	{
		[self setManagedObjectContext:context];
//		[self updateFile];
		ImageFile *foundImageFile = [self imageFileForFilePath:@"wazzle"];
		NSLog(@"found image %@",foundImageFile);
	}
	return self;
}

/**
 Search through the directory to find files that might need a low resolution version added
*/
- (void)processDirectory:(NSString*)directoryPath
{
	NSArray *HDSpecifiers = [NSArray arrayWithObjects:@"@2x",@"-hd", nil];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
	for (NSString *fileName in files)
	{
		// Check that we're dealing with a PNG file
		NSString *fileExtension = [fileName pathExtension];
		if([[fileExtension lowercaseString] isEqualToString:@"png"])
		{
			for (NSString *HDSpecifier in HDSpecifiers)
			{
				// Check the size of the filename
				if([fileName length] > [HDSpecifier length] + [fileExtension length] + 1)
				{
					// The -1 in the range is for the '.'
					NSRange expecetedRangeOfHDSpecifier = NSMakeRange([fileName length] - [HDSpecifier length] - [fileExtension length] - 1, [HDSpecifier length]);
					NSRange rangeOfHDSpecifier = [fileName rangeOfString:HDSpecifier options:NSLiteralSearch range:expecetedRangeOfHDSpecifier];
					if(rangeOfHDSpecifier.length > 0) //String is found
					{
						NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
						
						NSDate *fileModificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath error:nil] fileModificationDate];
						// Search for an image in the database with the same filepath
						ImageFile *imageFile = [self imageFileForFilePath:fullFilePath];
						
						NSString *standardResolutionFullFilePath = [directoryPath stringByAppendingPathComponent:[fileName stringByReplacingCharactersInRange:rangeOfHDSpecifier withString:@""]];
						// If the image is found, check the date
						if(imageFile)
						{
							// Check if the file is out of date
							if([[imageFile lastModifiedDate] compare:fileModificationDate] == NSOrderedAscending)
							{
								[imageFile createStandardResolutionCopyAtPath:standardResolutionFullFilePath];
								[imageFile setLastModifiedDate:fileModificationDate];
							}
							// Check that the low resolution copy hasn't been deleted
							else
							{
								if(![[NSFileManager defaultManager] fileExistsAtPath:standardResolutionFullFilePath])
								{
									[imageFile createStandardResolutionCopyAtPath:standardResolutionFullFilePath];
								}
							}
						}
						// If the image is not found, create a new entry in the database
						else 
						{
							imageFile = [self storeReferenceToFileAtPath:fullFilePath modificationDate:fileModificationDate];
							[imageFile createStandardResolutionCopyAtPath:standardResolutionFullFilePath];
						}
					}
				}
			}
		}
	}
	
	// Store all changes to the database in one transaction
	NSError *error;
	[[self managedObjectContext] save:&error];
	if(error)
	{
		NSLog(@"Error inserting new file %@",error);
	}
}

/**
 Do a Core Data query to find an image file
*/
- (ImageFile*)imageFileForFilePath:(NSString*)filePath
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"ImageFile" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filePath = %@", filePath];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *results = [moc executeFetchRequest:request error:&error];
	if(results == nil)
	{
		// An error has occurred
		return nil;
	}
	else
	{
		// Should be unique, and will return nil of empty
		return [results lastObject];
	}
}

/**
 Add a new entry into the database, without saving managed object context, which should be done afterwards
*/
- (ImageFile*)storeReferenceToFileAtPath:(NSString*)filePath modificationDate:(NSDate*)modifcationDate
{
	ImageFile *imageFile = [NSEntityDescription insertNewObjectForEntityForName:@"ImageFile" inManagedObjectContext:[self managedObjectContext]];
	[imageFile setFilePath:filePath];
	[imageFile setLastModifiedDate:modifcationDate];
	return imageFile;
}

@end
