/*
 * This file is a part of sample project which demonstrates how to use OpenCV
 * library with the XCode to write the iOS-based applications.
 * 
 * Written by Eugene Khvedchenya.
 * Distributed via GPL license. 
 * Support site: http://computer-vision-talks.com
 */

#import <Foundation/Foundation.h>

#import "ImageProcessingProtocol.h"

@interface ImageProcessingImpl : NSObject<ImageProcessingProtocol>
- (UIImage*) processImageSurf:(UIImage*) src;
- (NSString *)documentsPathForFileName:(NSString *)name;
-(int) saveDescriptor:(UIImage*) src secondParametar:(NSString *) name pathforFile:(NSString *) path isFirstItem:(int) firstItem;
-(int) searchImageInfo:(UIImage *)src pathForFile:(NSString *) path arrayOfDescriptors:(NSArray *) descriptors;
-(int) robustMatch:(UIImage*) src sceneImage:(UIImage*) scene;
@end
