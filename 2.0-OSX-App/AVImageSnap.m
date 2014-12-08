//
//  AVImageSnap.m
//  LifeSlice
//
//  Created by Stan James on 12/8/14.
//
//

#import "AVImageSnap.h"
#import <AVFoundation/AVFoundation.h>


/**
 * See: http://stackoverflow.com/a/3213017/59913
 */
@interface NSImage(saveAsJpegWithName)
- (void) saveAsJpegWithName:(NSString*) fileName;
@end

@implementation NSImage(saveAsJpegWithName)

- (void) saveAsJpegWithName:(NSString*) fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:fileName atomically:NO];
}

@end


@implementation AVImageSnap

+ (void) captureNowToFile:(NSString*)filepath
{
    AVCaptureStillImageOutput* stillImageOutput = [[AVCaptureStillImageOutput alloc] init];

    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
    {
        CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments)
        {
            // Do something with the attachments.
            NSLog(@"attachements: %@", exifAttachments);
        }
        else {
            NSLog(@"no attachments");
        }

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        NSImage *image = [[NSImage alloc] initWithData:imageData];

        [image saveAsJpegWithName:filepath];
        
    }];
    
}

@end
