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
- (BOOL) saveAsJpegWithName:(NSString*)fileName;
@end

@implementation NSImage(saveAsJpegWithName)

- (BOOL) saveAsJpegWithName:(NSString*)fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    return [imageData writeToFile:fileName atomically:NO];
}

@end


@implementation AVImageSnap {
    AVCaptureDevice* _device;
    AVCaptureDeviceInput* _input;
    AVCaptureStillImageOutput* _output;
    AVCaptureSession *_captureSession;
    AVCaptureConnection* _connection;
}


- (void) setupCamera
{
    // See: http://stackoverflow.com/a/23049092/59913
    
    NSError* error;
    _device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice: _device error:&error];
    if (!_input) {
        return;
    }
    
    _output = [AVCaptureStillImageOutput new];
    [_output setOutputSettings: @{(id)kCVPixelBufferPixelFormatTypeKey: @(k32BGRAPixelFormat)}];
    
    _captureSession = [AVCaptureSession new];
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    [_captureSession addInput: _input];
    [_captureSession addOutput: _output];
    [_captureSession startRunning];

    _connection = [_output connectionWithMediaType: AVMediaTypeVideo];

}


- (void) takePictureInstance:(NSString*)filepath
{
    [_output captureStillImageAsynchronouslyFromConnection: _connection
                                        completionHandler: ^(CMSampleBufferRef sampleBuffer, NSError* error) {
                                            
                                            if (error) {
                                                return;
                                            }
                                            else {
                                                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                                                
                                                if (imageBuffer) {
                                                    CVBufferRetain(imageBuffer);
                                                    
                                                    NSCIImageRep* imageRep = [NSCIImageRep imageRepWithCIImage: [CIImage imageWithCVImageBuffer: imageBuffer]];
                                                    
                                                    NSImage *resultImage = [[NSImage alloc] initWithSize: [imageRep size]];
                                                    [resultImage addRepresentation:imageRep];
                                                    
                                                    // Save it
                                                    BOOL success = [resultImage saveAsJpegWithName:filepath];
                                                    
                                                    CVBufferRelease(imageBuffer);
                                                }
                                            }
                                        }];
    
}


+ (void) takePictureToFile:(NSString*)filepath
{
    // See: http://stackoverflow.com/a/23049092/59913
    
    
    NSError* error;
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice: device error:&error];
    if (!input) {
        return;
    }
    
    AVCaptureStillImageOutput* output = [AVCaptureStillImageOutput new];
    [output setOutputSettings: @{(id)kCVPixelBufferPixelFormatTypeKey: @(k32BGRAPixelFormat)}];
    
    AVCaptureSession *captureSession = [AVCaptureSession new];
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    [captureSession addInput: input];
    [captureSession addOutput: output];
    [captureSession startRunning];
    
    double warmup = 2.0;
    
    AVCaptureConnection* connection = [output connectionWithMediaType: AVMediaTypeVideo];
    
    NSDate *now = [[NSDate alloc] init];
    [[NSRunLoop currentRunLoop] runUntilDate:[now dateByAddingTimeInterval: warmup]];
    
//    [NSThread sleepForTimeInterval: warmup];
    
    [output captureStillImageAsynchronouslyFromConnection: connection
                                        completionHandler: ^(CMSampleBufferRef sampleBuffer, NSError* error) {
                                            
                                            if (error) {
                                                return;
                                            }
                                            else {
                                                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                                                
                                                if (imageBuffer) {
                                                    CVBufferRetain(imageBuffer);
                                                    
                                                    NSCIImageRep* imageRep = [NSCIImageRep imageRepWithCIImage: [CIImage imageWithCVImageBuffer: imageBuffer]];
                                                    
                                                    NSImage *resultImage = [[NSImage alloc] initWithSize: [imageRep size]];
                                                    [resultImage addRepresentation:imageRep];
                                                    
                                                    // Save it
                                                    BOOL success = [resultImage saveAsJpegWithName:filepath];
                                                    
                                                    CVBufferRelease(imageBuffer);
                                                }
                                            }
                                        }];
    
}


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
