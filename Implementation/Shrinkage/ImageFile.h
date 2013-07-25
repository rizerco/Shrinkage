//
//  ImageFile.h
//  Shrinkage
//
//  Created by Luke Rogers on 11/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageFile : NSManagedObject

/** Full qualified path to HD asset */
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSDate *lastModifiedDate;

- (void)createStandardResolutionCopyAtPath:(NSString*)newFilePath;

@end
