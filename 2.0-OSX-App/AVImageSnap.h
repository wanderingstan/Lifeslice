//
//  AVImageSnap.h
//  LifeSlice
//
//  Created by Stan James on 12/8/14.
//
//


@interface AVImageSnap : NSObject 

- (void) setupCamera;
- (void) takePictureInstance:(NSString*)filepath;

+ (void) takePictureToFile:(NSString*)filepath;
+ (void) captureNowToFile:(NSString*)filepath;

@end
