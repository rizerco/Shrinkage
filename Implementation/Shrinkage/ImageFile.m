//
//  ImageFile.m
//  Shrinkage
//
//  Created by Luke Rogers on 11/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import "ImageFile.h"


@implementation ImageFile

@dynamic filePath;
@dynamic lastModifiedDate;

- (void)createStandardResolutionCopyAtPath:(NSString*)newFilePath
{
	if([self filePath])
	{
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:[self filePath]];
		NSLog(@"pixels high %ld",[(NSImageRep*)[[image representations] lastObject] pixelsWide]);
		NSImageRep* imageRepresentation = (NSImageRep*)[[image representations] lastObject];
		// There should be an image rep…
		if(imageRepresentation)
		{
			NSLog(@"mustafa %@",[[self filePath] stringByStandardizingPath]);
			NSSize newSize = CGSizeMake([imageRepresentation pixelsWide] / 2, [imageRepresentation pixelsHigh] / 2);
			[image setSize:newSize];
			
			NSImage *smallImage = [[NSImage alloc] initWithSize:newSize];
			[smallImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[image setSize:newSize];
			[image compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
			[smallImage unlockFocus];
			
			// Write to PNG
			NSData *imageData = [smallImage TIFFRepresentation];
			NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
			NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor];
			imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
			[imageData writeToFile:newFilePath atomically:NO];
		}
		else
		{
			NSLog(@"Ubable to assertain image size.");
		}
	}
}

@end
