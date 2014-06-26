/*
 * This file is a part of sample project which demonstrates how to use OpenCV
 * library with the XCode to write the iOS-based applications.
 * 
 * Written by Eugene Khvedchenya.
 * Distributed via GPL license. 
 * Support site: http://computer-vision-talks.com
 */

#import "ImageProcessingImpl.h"
#import "OpenCVImageProcessor.h"
#import "RobustMatcher.h"


@implementation ImageProcessingImpl



//funkcii koj gi koristam jas a ne bea vo templejtov



-(int) saveDescriptor:(UIImage*) src secondParametar:(NSString *) name pathforFile:(NSString *) path
{
    OpenCVImageProcessor processor;
    path=[self documentsPathForFileName:path];
    cv::Mat srcImage=[self cvMatFromUIImage:src];
    return processor.saveImageDescriptor(srcImage,new std::string([name UTF8String]), new std::string([path UTF8String]));
   
}

-(int) searchImageInfo:(UIImage *)src pathForFile:(NSString *) path arrayOfDescriptors:(NSArray *) descriptors
{
    int length=[descriptors count];
    std::vector<std::string> desc;
        for(int i=0;i<length;i++){
        desc.push_back(*new std::string([[[descriptors objectAtIndex:i] objectForKey:@"name"] UTF8String]));
        NSLog(@"%@",[[descriptors objectAtIndex:i] objectForKey:@"name"]);
        std::cout<<desc[i]<<"\n";
    }
    OpenCVImageProcessor processor;
    cv::Mat srcImage=[self cvMatFromUIImage:src];
    path=[self documentsPathForFileName:path];
    
    return processor.getImageInfo(srcImage, new std::string([path UTF8String]), desc);
}

-(int) robustMatch:(UIImage*) src sceneImage:(UIImage*) scene
{
    RobustMatcher matcher;
    std::vector<cv::DMatch> matches;
    std::vector<cv::KeyPoint> keypoints1, keypoints2;
    cv::Mat srcImage=[self cvMatFromUIImage:src];
    cv::Mat sceneImage=[self cvMatFromUIImage:scene];
    cv::Mat srcImagegray,sceneImageGray;
    cv::cvtColor( srcImage,srcImagegray, cv::COLOR_BGR2GRAY);
    cv::cvtColor( sceneImage,sceneImageGray, cv::COLOR_BGR2GRAY);
    return matcher.match(srcImagegray,sceneImageGray,matches,keypoints1,keypoints2);
    
}



- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}
/*
 * Convert ui image to cv::Mat
 */
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

/**
 * Tconvert cv::Mat to UIImage
 */

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
@end
