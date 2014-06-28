#import <Foundation/Foundation.h>

@protocol ImageProcessingProtocol <NSObject>
- (UIImage*) processImageSurf:(UIImage*) src;


- (NSString *)documentsPathForFileName:(NSString *)name;
-(int) saveDescriptor:(UIImage*) src secondParametar:(NSString *) name pathforFile:(NSString *) path isFirstItem:(int) firstItem;
-(int) searchImageInfo:(UIImage *)src pathForFile:(NSString *) path arrayOfDescriptors:(NSArray *) descriptors;
-(int) robustMatch:(UIImage*) src sceneImage:(UIImage*) scene;
@end
